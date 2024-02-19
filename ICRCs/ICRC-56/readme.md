|ICRC|Title|Author|Discussions|Status|Type|Category|Created|
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|56|File System and Asset Canisters|Austin Fatheree (@skilesare),|https://github.com/dfinity/ICRC/issues/56|Idea|Standards Track||2024-02-04|


# Storage

## Infinitely Scalable Multi-Canister File System

The canister file system (CFS) in the Internet Computer ecosystem is designed to offer infinitely scalable storage using a multi-canister architecture. This scalability is achieved through the capability to create and manage a network of interconnected canisters, each tailored to handle specific parts of the file system workload.

### Mounting Storage Canisters

To facilitate this scalability, storage canisters can be dynamically mounted to the file system. Mounting is the process of logically integrating an independent storage canister into the main file system hierarchy, making its storage capacity and contents an integral part of the overall file system.

#### Mounting Procedure

The mounting procedure involves invoking the `icrc56_mount_storage` method within a FileSystem canister with details of the storage canister to mount.

```candid
type StorageDetails = record {
    canister_id: principal; // The principal ID of the storage canister to mount
    capacity: nat; // The storage capacity offered by this storage canister
    // Additional configuration details specific to the storage canister can be added here.
};

type MountStorageResponse = variant {
    Ok: record { mount_id: nat }; // Unique identifier for the mounted storage
    Err: text; // Error message if the mounting operation fails
};

// The mount_storage method allows integrating an additional storage canister into the file system.
icrc56_mount_storage : (details: StorageDetails) -> (MountStorageResponse) update;
```

#### Authorization

Only principals with `Commit` permissions on the FileSystem canister are authorized to call `icrc56_mount_storage`. This restriction ensures that only trusted actors are able to modify the configuration of the file system. Any unauthorized attempts SHOULD result in an `Unauthorized` error.

#### Atomicity and Consistency

The mounting process SHOULD be atomic to ensure that the file system's state is consistent and that partial mounts do not occur. In the event of a failure during the mount operation, the file system MUST revert to its previous state, maintaining data integrity.

#### Use of Mounted Storage

Once a storage canister is mounted, it becomes a seamless part of the file system. All operations that were previously directed to the primary storage space can now utilize the additional capacity provided by the mounted canister. The distribution of files and load between the primary and mounted storage is typically managed by the file system's internal algorithms, which are designed to balance workload and optimize performance.

When a file is staged through the staging process it is written to a selected storage canister and the chunk allocation system is responsible for maintaining its location for retrieval.

Each storage canister is responsible for maintaining its own certified asset tree.

### Retrieving Content Across Canisters

The file system provides functionality to retrieve assets and contents from multiple storage canisters. This is managed through the `icrc56_get_chunk` and `icrc56_get` methods, which may return a callback if the requested item resides on another canister within the multi-canister architecture.

#### Expanded ChunkResponse

The following updates to `ChunkResponse` are proposed to handle retrieval from other canisters:

```candid
type ChunkResponseVariant = variant {
    LocalChunk: record {
        content: blob; // The actual bytes of the chunk
    };
    RemoteChunkCallback: record {
        callback: principal; // The principal ID of the canister holding the chunk
        request_details: RequestDetails; // Details such as chunk ID required to fetch the chunk
        // Additional details specific to the remote callback can be added here.
    };
};

type GetChunkResponse = record {
    chunk_response: ChunkResponseVariant;
};
```

#### Updated icrc56_get variant

For `icrc56_get`, an analogous variant must be added to support callback mechanisms when the asset is hosted on a different storage canister. The updated response variant would look like this:

```candid
type GetResponseVariant = variant {
    LocalAsset: EncodedAsset; // The asset is locally available
    RemoteAssetCallback: record {
        callback: principal; // The principal ID of the canister holding the asset
        request_details: RequestDetails; // Details required to fetch the asset
        // Additional details specific to the remote callback can be added here.
    };
};

// Method to get an asset, which may now return a remote callback reference
icrc56_get : (arg: GetArg) -> (GetResponseVariant) query;
```

These updates to the `ChunkResponse` and `icrc56_get` method responses allow for the seamless retrieval of content across a diverse storage infrastructure, adhering to an infinitely scalable file system approach within the DFINITY Internet Computer ecosystem.

# Using the `http_request` Endpoint for Asset Retrieval

As part of the ICRC-56 standard for the Canister File System (CFS), implementation of an `http_request` endpoint is essential for retrieving assets via HTTP from storage canisters. The `http_request` endpoint conforms to the HTTP standards for web interactions and should support HTTP methods such as GET for asset retrieval.

## Asset Accessibility

### Public Assets 
Publicly readable assets are readable by anyone without any special authentication or permission checks. These assets can be served directly by the `http_request` endpoint, making them available to any HTTP client.

### Restricted Assets
For assets that are restricted to a principal or a group, the requester must acquire an `http_access` token by calling the `icrc56_get_asset_token` method to receive a random 32-byte blob. This blob must be signed by the requester's principal and included in the HTTP request headers for authorization purposes.

## Handling Redirects

When an HTTP client requests an asset that resides on a storage canister, the main file system serving the request should respond with an HTTP 301 Permanent Redirect to the URL of the actual asset on the storage canister. It is vital that the main FS system includes a certified header with all redirects so that clients can verify the authenticity of the redirect response.

## Endpoint Description

### `http_request` Method
The endpoint processes incoming HTTP requests and retrieves the requested assets or redirects the client as necessary.

#### Input
- The HTTP request details, including the path, headers, method (GET for retrieval), and other standard HTTP request fields.

#### Processing
1. The system determines the location of the requested asset (main FS or a specific storage canister).
2. For publicly readable assets, the system fetches and returns the asset.
3. For assets on storage canisters, the system issues an HTTP 301 with the location header set to the storage canister's URL.
   - The response includes a certificate for the redirect (v2 certification) in the headers.
4. For restricted assets, the system validates the signed `http_access` token present in the request headers.
5. If the token or signature is invalid, the system returns an appropriate HTTP error code (e.g., 403 Forbidden).

#### Output
- Depending on the request and asset location, the output is either the asset content or an HTTP redirect response with proper certification. Restricted assets may also result in an HTTP error if authorization fails.

## Security Mechanisms

### Certification of Redirects
All redirects from the main FS system must be accompanied by a certified header that clients can use to verify the authenticity of the redirect. The certification process ensures that clients are directed to the correct storage canister and asset.

### Access Tokens for Restricted Assets
Restricted assets require an additional authorization step. Clients must first obtain an `http_access` token from the `icrc56_get_asset_token` method, sign it with their principal's private key, and include this signed token in the headers of HTTP requests.

### Random Beacons for Redirect Validation
To prevent stale redirects and ensure valid authorization checks, implementors MAY choose to include a random beacon mechanism. The main FS system can generate a random beacon at regular intervals—e.g., using a decentralized randomness beacon on the Internet Computer—and pass it to storage canisters. Storage canisters can use this beacon to invalidate old redirects, forcing clients to obtain new, validated redirects in a timely manner.

## Considerations for Implementors

- Compliance with the HTTP specification for interoperability with web clients.
- Proper handling of authentication and authorization for restricted assets.
- Efficient and secure mechanism for issuing and validating `http_access` tokens.
- Use of certified responses to ensure the trustworthiness of redirects and asset retrieval.

### Path Considerations

The implementor has two choices on how to expose the file system:

1. root of the canister: ie https://canisterid.icp0.io/PATH 
2. namespaced endpoint using ICRC-23 standard domain namespacing https://canisterid.icp0.io/---/icrc56/PATH

The second is necessary for canisters that may also want to expose an http dapp at the root of their canister.

## Data Representation

### Overview

This section outlines the representation of specific data types used within the ICRC-56 Canister File System standard. These types are integral to the various operations that can be performed on the canister file system, including batch operations, permission management, and asset handling.

### Type Definitions


#### AssetKey

An `AssetKey` represents a unique identifier for an asset within the canister. It is a URL path that points to the location of the asset. The `AssetKey` must be a valid URL path segment, which can be used to fetch or reference the asset within the file system. An example of an `AssetKey` could be a string like "/images/profile.jpg" or "/docs/readme.md".

```candid
// Defines the identifier for an asset in the file system.
type AssetKey = text;
```

#### BatchId

is used to track and identify a collection of related file system operations that are intended to be committed together. This identifier helps in grouping operations into atomic units for processing.

```candid
// Represents an identifier for a batch of operations.
type BatchId = nat;
```

#### ChunkId

helps manage large files that must be broken down into smaller chunks due to the ingress message size restrictions on the Internet Computer. Each chunk can be individually addressed using its unique `ChunkId`.

```candid
// Represents an identifier for a specific chunk within a batch.
type ChunkId = nat;
```

#### Permission

is an enumerated type that specifies the kinds of actions an entity is authorized to perform in the context of the file system. There are three possible permissions:

  - `Commit`: Allows the committing of batch operations to the file system.
  - `ManagePermissions`: Grants the ability to manage permissions for other identities within the file system.
  - `Prepare`: Permits the preparation of batches and chunks but does not allow committing them to the file system.

```candid
// Describes the type of permissions available in the canister file system.
type StagePermission = variant {
    Commit;
    ManagePermissions;
    Prepare;
};
```
#### BatchOperation

denotes the type of change being proposed in a batch of file system operations. The variants correspond to actions such as creating a new asset, setting the content of an asset, removing content from an asset, deleting an asset entirely, clearing all assets, and setting properties of an asset.

```candid
// Enumerates the various types of batch operations that can be applied.
type BatchOperation = variant {
    CreateAsset;
    SetAssetContent;
    UnsetAssetContent;
    DeleteAsset;
    Clear;
    SetAssetProperties;
};
```

#### GrantPermissionArguments

Contains the recipient principal and the specific permission to be granted.

```candid
// Arguments for granting a permission to a principal.
type GrantStagePermissionArguments = record {
    to_principal: principal;
    stage_permission: StagePermission;
};
```

#### RevokePermissionArguments

Specifies the principal and the permission that needs to be revoked.

```candid
// Arguments for revoking a permission from a principal.
type RevokePermissionArguments = record {
    of_principal: principal;
    stage_permission: StagePermission;
};
```

#### ListPermittedArguments

Used to retrieve a list of principals that have been granted a particular permission.

```candid
// Arguments for listing principals with a specific permission.
type ListStagePermittedArguments = record {
    state_permission: StagePermission;
};
```

#### CreateAssetArguments

Defines the properties for creating a new asset, such as the asset key, content type, maximum age, headers, aliasing options, and raw access permission.

```candid
// Arguments for creating a new asset in the canister file system.
type CreateAssetArguments = record {
    key: AssetKey;
    content_type: text;
    max_age: opt nat;
    headers: opt record {text; text;};
    enable_aliasing: opt boob;
    allow_raw_access: opt bool;
    asset_permission: AssetPermission;
};
```

#### SetAssetContentArguments

Specifies the asset key, the content encoding to be used, the chunk IDs that contain the asset data, and an optional SHA-256 checksum.

```candid
// Arguments for setting the content of an asset using specific chunks.
type SetAssetContentArguments = record {
    key: AssetKey;
    content_encoding: text;
    chunk_ids: vec ChunkId;
    sha256: opt blob;
    
};
```

#### UnsetAssetContentArguments

Used to remove a particular content encoding from an asset.

```candid
// Arguments for unsetting the content of an asset, effectively removing a specific encoding.
type UnsetAssetContentArguments = record {
    key: AssetKey;
    content_encoding: text;
};
```

#### DeleteAssetArguments

Defines the asset to be deleted based on its key.

```candid
// Arguments for deleting an existing asset from the canister file system.
type DeleteAssetArguments = record {
    key: AssetKey;
};
```

### CommitBatchArguments

Contains information necessary to commit a batch of operations to the file system, specifying the `batch_id` and the sequence of `operations` to be applied.

```candid
// Arguments for committing a prepared batch of operations.
type CommitBatchArguments = record {
    batch_id: BatchId;
    operations: vec BatchOperation;
};
```

#### StoreArg

Describes the arguments needed for storing a single asset within the file system, including the asset key, content type, content encoding, the actual content in bytes, an optional SHA-256 checksum, and an aliasing option.

```candid
// Arguments for storing data as an asset within the file system.
type StoreArg = record {
    key: AssetKey;
    content_type: text;
    content_encoding: text;
    content: blob;
    sha256: opt blob;
    aliased: opt blob;
    asset_permissions: AssetPermission;
};
```

#### GetArg

Specifies what asset is requested based on the asset key and the acceptable content encodings.

```candid
// Arguments for retrieving an asset from the file system.
type GetArg = record {
    key: AssetKey;
    accept_encodings: vec text;
};
```

#### GetChunkArg

Indicates the criteria for retrieving a chunk of an asset by specifying the asset key, desired content encoding, the index of the chunk, and an optional SHA-256 checksum for verification.

```candid
// Arguments for retrieving a specific chunk of an asset.
type GetChunkArg = record {
    key: AssetKey;
    content_encoding: text;
    index: nat;
    sha256: opt blob;
};
```

#### CreateBatchResponse

The response from creating a batch containing the unique identifier for the batch, allowing further actions to be associated with it.

```candid
// The response returned when a new batch is successfully created.
type CreateBatchResponse = record {
    batch_id: BatchId;
};
```

#### CreateChunkArg

Describes what content should be added as a new chunk in a specific batch operation.

```candid
// Arguments for creating a new chunk of data within a batch operation.
type CreateChunkArg = record {
    batch_id: BatchId;
    content: blob;
};
```

#### CreateChunkResponse

The response after successfully creating a chunk in a batch, including the generated `chunk_id` that uniquely identifies this chunk.

```candid
type CreateChunk Error = variant {
  #Unauthorized;
  #TooLarge;
  #BatchNotFound;
};

// The response returned when a new chunk is successfully created in a batch.
type CreateChunkResponse = record {
    #Ok: ChunkId;
    #Err: CreateChunkError;
};
```

### AssetProperties

The `AssetProperties` structure encapsulates various metadata and control properties of an asset. This includes optional headers, caching policies implied by maximum age, and access controls like the ability to fetch asset raw content or its aliasing status.

```candid
// Describes the metadata and control properties associated with an asset.
type AssetProperties = record {
    max_age: opt nat64;  // Cache control (max-age in seconds) for the asset.
    headers: opt vec record {text; text};  // HTTP headers to be returned with the asset.
    allow_raw_access: opt bool;  // If true, permits raw access to the asset without certification.
    is_aliased: opt bool;  // Indicates if the asset is an alias to another asset.
    asset_permissions: AssetPermission;
};
```

#### SetAssetPropertiesArguments

The `SetAssetPropertiesArguments` structure dictates the arguments required when setting the properties for an asset. This allows granular control over the properties that can be set or unset and includes changing cache control settings, response headers, raw access allowances, and aliasing configurations.

```candid
// Arguments for setting or updating the properties of an existing asset.
type SetAssetPropertiesArguments = record {
    key: AssetKey;
    max_age:opt opt nat;
    headers: opt opt record{ text; text;};
    allow_raw_access: opt opt bool;
    is_aliased: opt opt bool;
    asset_permissions: opt AssetPermission;
};
```

### SetStagePermissions

`SetPermissions` describes the structure required for setting permissions for various principals. It contains lists of principals categorized by the specific permissions they should have after the settings operation completes.

```candid
// Defines permission settings for a list of principals.
type SetStagePermissions = record {
    prepare: vec principal;  // Principals with 'Prepare' permission.
    commit: vec principal;   // Principals with 'Commit' permission.
    manage_permissions: vec principal;  // Principals with 'ManagePermissions' permission.
};
```

### AssetPermissionDetail

`AssetPermission` is a type that quantifies the set of admissible actions that can be performed on a deployed asset within the file system. This could range from read-write access to more restricted actions, depending on the implementation requirements.

```candid
type AssetPermissionDetail = variant {
    Read: AssetPermissionList;
    Write: AssetPermissionList;
    List: AssetPermissionList;
    Permissions: AssetPermissionList;
};
```

### AssetPermission

`AssetPermission` is a type that describes the type of asset being updated.

```candid
type AssetPermission = variant {
    Read;
    Write;
    List;
    Permissions;
};
```

### AssetPermissionList

An `AssetPermissionList` is an ordered collection of `AssetPermission` values that enumerates the permissions assigned to a specific asset or a set of assets. This list is used to verify if an operation performed by a principal on an asset is allowed within the file system.

```candid
type AssetPermissionList = vec variant{
  User : principal
  Group : record {
    namespace: text;
    canister: principal;
  };
};
```

### ListRequest

A `ListRequest` is a request for items at a particular path on the file server

```candid
type ListRequest = record{
  path: text;
  recursive: bool;
  name_filter: ?text; //filter pattern
  size_filter : ?variant {
    lt: nat;
    gt: nat;
  };
  details: bool; //true to include encoding details
  dir: bool; //do you want directories
};
```

### CopyRequest

A `CopyRequest` is a request for copying an asset from one path to another

```candid
type CopyRequest = record{
  from: AssetPath;
  to: AssetPath;
  overwrite: bool;
};
```

### RenameRequest

A `RenameRequest` is a request for renaming an asset from one path to another

```candid
type RenameRequest = record{
  from: AssetPath;
  to: AssetPath;
  overwrite: bool;
};
```

## Return Types

### RetrieveResponse

```candid
type RetrieveResponse = variant {
  #Eof: blob; //used to denote this is the last of a file.
  #Chunk: record{blob; nat; nat;};  //blob of the file, index of chunk, and number of chunks
};
```

### StoreArgResponse

```candid
type StoreErr = {
  #Unauthorized;
  #HashMismatch: record{given:blob; calculated:blob;};
};

type StoreArgResponse = {
  #Ok: nat; //trx id of the store record
  #Err: StoreErr;
};
```

### CreateBatchResponse

```candid
type CreateBatchError = variant {
  #TooManyBatches;
};

type CreateBatchResponse = variant {
  #Ok: record{ 
    trx_result: nat; //trx id of the store record
    batch_id : nat; //new batch id
  }; 
  #Err: CreateBatchErr;
};
```

### CommitBatchResponse

```candid
type CommitBatchError = variant {
  #Unauthorized;
  #BatchNotFound: BatchCommand;
  #AssetNotFound : BatchCommand;
};

type CommitBatchResponse = variant {
  #Ok: vec (variant { 
    CreateAsset : nat; //transaction where the asset is created
    SetAssetContent: nat; //transaction where the asset is updated
    UnsetAssetContent: nat;  //transaction where the asset is updated
    DeleteAsset : nat;  //transaction where the asset is updated
    Clear: vec nat; //transactions where commited objects are cleared
    SetAssetProperties : nat;  //transaction where the asset is updated
  }); 
  #Err: CommitBatchError;
};
```

## Methods

### Method Overview

The methods section defines the functionality offered by the Canister File System, covering operations related to asset management, file chunk handling, permissioning, and metadata retrieval. Here, we propose a comprehensive list of methods essential for maintaining the integrity and operation of the file system.

### Method Definitions

## icrc56_mount_storage

### Summary
The `icrc56_mount_storage` method is used to integrate additional storage canisters, effectively scaling the canister file system beyond the individual canister's storage limits. This method is crucial for implementing the infinitely scalable storage architecture within the Internet Computer ecosystem.

### Function Signature
```candid
// Mounts an additional storage canister to the file system.
icrc56_mount_storage : (details: StorageDetails) -> (MountStorageResponse) update;
```

### Pre-conditions
1. The caller MUST have `Commit` permissions on the FileSystem canister.
2. The `details` provided MUST contain the necessary information (e.g., `canister_id`, `capacity`) to properly integrate the additional storage canister.
3. If the canister id is provided, the FileSystem canister must be a controller on that canister and it must have the FileSystem Storage wasm installed on the canister.

### Post-conditions
1. The storage canister referenced in `StorageDetails` is linked to the FileSystem.
2. The `MountStorageResponse` indicates the success or failure of the operation.

### Arguments
- `details: StorageDetails`: A record containing the principal ID, capacity, and other relevant details of the storage canister being mounted.

### Response
- `MountStorageResponse`: May contain the unique identifier `mount_id` for the successfully mounted storage or an error message indicating the reason for a failure.

### Example Use Case in Motoko (Annotated)
```motoko

type StorageDetails = {
  canister_id: ?Principal; //if the principal is empty the canister will attempt to spawn a new canister
  available_size: 4_000_000_000; //4GB
  reserved_size: 0; //if more than 0, the space will be reserved on the subnet
};

// Assume a management function within a front-end canister or administrative script
public func addStorage(details: StorageDetails) : async () {
  // Call the file system's mount storage method with the provided storage canister details
  let result = await FileSystemCanister.icrc56_mount_storage(details);

  // Handle the result based on the outcome of the mount operation
  switch (result) {
    case (#Ok(mount_id)) {
      Debug.print("Storage canister mounted with ID: " # Nat.toText(mount_id));
    };
    case (#Err(error)) {
      Debug.print("Failed to mount storage canister: " # error);
    };
  }
}
```


#### icrc56_store

##### Summary

The `icrc56_store` method allows for storage of an asset within a canister, facilitating the handling of assets that exceed the 2MB ingress limit by accepting chunked file data and associated metadata for asset creation or update.

```candid
icrc56_store : (args: vec StoreArg) -> async vec StoreArgResponse update;
```

##### Pre-conditions
1. Caller SHOULD be authorized by the canister with a `Commit` permission to invoke this method. Otherwise, the request is rejected with `Unauthorized`.
2. An asset corresponding to the provided `AssetKey` MUST NOT exist if this is a create operation, or it MUST exist if it is an update operation.

##### Post-conditions
1. If creation, a new asset is created with the provided content and associated metadata.
2. If update, the existing asset is updated with the new content and/or metadata.
3. The operation generates a transaction index which can be used for referencing this particular store operation in the future. The canister SHOULD integrate this with ICRC-3 for a complete transaction log.

### Arguments
- `args: vec StoreArg`: A set of records containing the `AssetKey`, content type, content encoding, the actual bytes to be stored (`content`), possibly a SHA-256 hash of the content (`sha256`), and an indication of whether the asset is to be aliased (`aliased`).

### Errors
- `Unauthorized`: The calling principal does not have the `Commit` permission.
- `HashMismatch`: Provided `sha256` does not match the computed hash of the `content`.
- Other errors as determined by the canister's specific implementation and error handling strategy.

### Return Value
- On success, each input vector returns a `nat` representing the transaction index.
- On failure, each input vector member returns `StoreError` indicating the specific error encountered.

### Example

```motoko

    let storeArg = {
      key = key;
      content_type = "text/plain";  // Assuming plain text for example
      content_encoding = "identity";  // No additional encoding or compression
      content = content;  // The actual content of the asset
      sha256 = null;  // No hash provided for simplicity
      aliased = false;  // Not an alias in this example
    };
    
    
    // Call the `icrc56_store` method on the target canister
    let result : Result<Nat, StoreError> = await canisterActor.icrc56_store([request]);

```


#### icrc56_create_batch

The `icrc56_create_batch` method is used to initiate a new batch of file system operations. A batch is a collection of operations that are prepared and eventually committed together to maintain an atomic transactional behavior. The method returns a `CreateBatchResponse`, containing either the `batch_id` for the created batch or an error message indicating why the batch could not be created.

```candid


type CreateBatchResponse = variant {
  #Ok: record{ 
    trx_result: nat; //trx id of the store record
    batch_id : nat; //new batch id
  }; 
  #Err: CreateBatchErr;
};

type CreateBatchError = variant {
  #TooManyBatches;
  #Unauthorized;
};


icrc56_create_batch : (number : opt nat) -> async (vec CreateBatchResponse) update;
```

##### Pre-conditions

1. Caller SHOULD be authorized by the canister with a `Commit` or `Prepare` permission to invoke this method. Otherwise, the request is rejected with `Unauthorized`.
2. The total number of open batches MUST NOT exceed the `icrc56:max_batches` limit.
3. The canister state MUST be free from any errors that would prevent batch creation.

##### Post-conditions

1. A new batch is created and associated with a unique `BatchId`.
2. The batch is initially empty and ready to have asset operations added to it.

##### Arguments
- `number: opt Nat`: The number of batch_ids you would like generated.  Default is one.

##### Response
- `vec CreateBatchResponse`: Each new batch ID should have a #Ok(nat) response. If an error occurs then an #Err(...) should be returned.

##### Example

```motoko

actor {

    // Attempt to create a new batch
    let response = await FileCanister.icrc56_create_batch(null);
    
    // Check the response and handle according to result
    switch (response[0]) {
      case (#Ok(batch)) {
        Debug.print("New batch created with id: " # Nat.toText(batch.batch_id));
        return #ok(batch);
      };
      case (#Err(error)) {
        Debug.print("Failed to create batch: " # error);
        return #err(error);
      };
    }
  };
```

#### icrc56_create_chunk


The `icrc56_create_chunk` method is for adding a chunk of data to the file system for inclusion in a batch. This method is particularly useful for uploading large assets in smaller increments. The method accepts a `CreateChunkArg` with the `batch_id` and the binary data for the chunk content.

Given that the purpose of the create chunk function is to upload chunks at the ingress file limit the standard does not provide a batch by default type interface for the function.

```candid
 icrc56_create_chunk : (args: CreateChunkArg) -> async (CommitChunkResponse) update;
```

##### Pre-conditions

1. The caller SHOULD be authorized by the canister with a `Commit` or `Prepare` permission.
2. The `batch_id` provided MUST reference an existing batch.
3. The total size of the batch after adding the new chunk MUST NOT exceed `icrc56:max_bytes`.

##### Post-conditions

1. The chunk is added to the batch associated with the provided `batch_id`.
2. A `CreateChunkResponse` is returned which contains the `ChunkId` of the newly created chunk.

##### Arguments
- `args: CreateChunkArg`: The details of the chunk.

##### Response
- `CommitChunkResponse`: If the chunk is succesful then #Ok({trx_id: nat; chunk_id: nat}) response providing information about the resulting transaction and the saved chunk_id. If an error occurs then an #Err(...) should be returned.

###### Example

```motoko

    // Prepare the arguments for creating a chunk
    let args = {
      batch_id = batchId;
      content = content;
    };

    // Attempt to create a chunk in the batch
    let response = await FileCanister.icrc56_create_chunk(args);
    
    // Check the response and handle according to result
    switch (response) {
      case (#Ok(chunk)) {
        Debug.print("New chunk created with id: " # Nat.toText(chunk.chunk_id));
        return #ok(chunk);
      };
      case (#Err(error)) {
        Debug.print("Failed to create chunk: " # error);
        return #err(error);
      };
    }
 
```

#### icrc56_commit_batch

The `icrc56_commit_batch` method commits a batch of file system operations in a single atomic action. It ensures that all operations within the batch are applied together, maintaining data consistency. It accepts `CommitBatchArguments` which includes the `batch_id` and operations to be committed.

```candid
 icrc56_commit_batch : (args: vec CommitBatchArguments) -> async CommitBatchResponse update;
```

##### Pre-conditions

1. The caller SHOULD be authorized by the canister with with a `Commit` permission.
2. The `batch_id` provided MUST reference an existing batch.
3. All operations within the batch MUST be valid and executable.

##### Post-conditions

1. The batch is atomically committed to the file system.
2. A `CommitBatchResponse` is returned containing transaction indexes for each operation in the batch or an error.

##### Arguments
- `args: vec CommitBatchArguments`: The set of batch commands that you want executed atomically.

##### Response
- `CommitBatchResponse`: If the atomic transaction is successful, Each transaction_id created during execution will be in the  #Ok(vec nat) response in the order of execution. If a validation error occurs then an #Err(...) SHOULD be returned. If one of the operations fails during atomic execution because a batch or asset is removed by a previous command then the canister MAY trap to revert state.

##### Example

```motoko

    let args = {
      batch_id = batchId;
      operations = ...; // Define operations here
    };

    // Attempt to commit the batch
    let response = await FileCanister.icrc56_commit_batch(args);
    
    // Check the response and handle according to result
    switch (response) {
      case (#Ok(trxIndexes)) {
        Debug.print("Batch committed successfully with transaction indexes: " # ...);
        return #ok(trxIndexes);
      };
      case (#Err(error)) {
        Debug.print("Failed to commit batch: " # error);
        return #err(error);
      };
    };
```

#### get

The `icrc56_get` method retrieves encoded assets along with their metadata. It is a query method that ensures no state changes occur within the canister. It accepts `GetArg` with the `AssetKey` and a list of acceptable content encodings.

```candid
icrc56_get : (args : vec GetArg) -> async (vec (opt EncodedAsset)) query;
```

#### Pre-conditions

1. If READ permissions are set for an asset, the caller MUST be authorized to READ the asset.
2. The `AssetKey` provided MUST reference an existing asset.

#### Post-conditions

1. Returns the first acceptable `EncodedAsset` that contains the asset data, content type, content encoding, total length, and optional SHA-256 checksum.
2. If the asset is not found or the requested encoding is not available, a `null` is provided as a response for that asset request in the response vector.

### icrc56_get_chunk

#### Summary
The `icrc56_get_chunk` function retrieves a specific segment or chunk of an asset's content based on the requester's provided index and encoding requirements. It is part of the process for handling content that exceeds the ingress message size, enabling the transfer of large files in smaller parts.

#### Function Signature
```candid
icrc56_get_chunk : (arg : GetChunkArg) -> async (GetChunkResponse) query;
```

#### Pre-conditions
1. `arg.key` MUST correspond to an existing asset within the canister.
2. `arg.index` MUST be a valid index corresponding to an existing chunk of the asset. Indexes are zero-based.
3. `arg.content_encoding` MUST match one of the available content encodings for the asset.
4. If `arg.sha256` is provided, it MUST match the SHA-256 hash of the concatenated chunks of the asset for the specified encoding.

#### Post-conditions
1. The function returns a `GetChunkResponse` containing the requested chunk content if all pre-conditions are met.
2. If the `sha256` field is provided and matches, it validates the integrity of the chunk content.

#### Example Use Case in Motoko
```motoko
// Define the arguments to retrieve a specific chunk
let getChunkArg = {
    key = "/path/to/large/asset.mp4",
    content_encoding = "identity",
    index = 5 : Nat, // assuming we want the 6th chunk (zero-based index)
    sha256 = ?ExpectedHash // optional SHA-256 hash
};

// Call the icrc56_get_chunk function of the FileCanister
let response = await FileCanister.icrc56_get_chunk(getChunkArg);

// Handle the response
switch (response) {
    case (#ok(chunkData)) {
        // Successfully retrieved the chunk data
        // Process the chunk as needed
        HttpAgent.respond(chunkData);
    };
    case (#err(error)) {
        // Handle error case
        HttpAgent.respondWithError(error);
    };
};
```

In this example, we import necessary modules, prepare the `GetChunkArg` with required fields, call the `icrc56_get_chunk` function, and handle the response which could be a successful chunk retrieval or an error case.

### get_asset_properties

#### Summary
The `get_asset_properties` method is designed to retrieve various properties of an asset within the Internet Computer's Canister File System defined by the ICRC-56 standard. It allows users to understand how assets are served, their metadata, caching information, HTTP headers, and access permissions.

#### Function Signature
```candid
// Retrieves properties of a given asset by its key.
get_asset_properties : (key: AssetKey) -> (AssetProperties) query;
```

#### Pre-conditions
- The asset identified by `key` MUST exist within the canister. If the asset does not exist, the method will return an error.

#### Post-conditions
- Upon successful execution, the method returns an `AssetProperties` record containing the asset's properties.

#### Example Use Case in Motoko (Annotated)
```motoko

// Define an asset key for which properties are to be retrieved
let assetKey = "/images/photo.png";

// Call the get_asset_properties method to fetch asset properties
let properties : AssetProperties = await FileCanister.get_asset_properties(assetKey);

// `properties` now contains various metadata about the asset.
// For example, display the asset's max age for caching purposes
Debug.print("Max age: " # (properties.max_age != null ? Nat64.toText(properties.max_age.val) : "N/A"));
```

### set_asset_service_properties

#### Summary
The `set_asset_service_properties` method allows canister administrators or authorized users to configure properties associated with an asset. This includes setting HTTP headers, caching policies, and access permissions for the asset.

#### Function Signature:
```candid
// Sets the service properties of a list of assets.
icrc56_set_asset_service_properties : (vec record{key: AssetKey, properties: AssetProperties}) -> async (vec AssetProperties) query;
```

#### Pre-conditions:
- The caller MUST be authorized with `Commit` access for the asset identified by each `AssetKey`. If the caller is not authorized, the operation will result in an error.
- Each `AssetKey` in the `vec record` MUST correspond to an existing asset. If an `AssetKey` does not exist, the operation will result in an error for that key.
- The `AssetProperties` structure must be properly formed with valid settings for cache control, headers, aliasing options, and raw access permissions.

#### Post-conditions:
- The asset identified by each `AssetKey` will have its properties updated to reflect those provided in the corresponding `AssetProperties` structure.
- Returns a `vec AssetProperties` reflecting the new state of each asset's properties. In case of an error, appropriate error values will be returned describing the failure for each asset.

#### Example Use Case in Motoko (Annotated):

```motoko

  // Define the asset key and the new properties you wish to set
  let assetKey = "/images/photo.png";
  let newProperties = {
    max_age = ?(3600 : nat64); // Set cache control max-age to 1 hour
    headers = ?[("Content-Type", "image/png")]; // Set the Content-Type header
    allow_raw_access = ?true; // Allow raw access to the asset without certification
    is_aliased = ?false; // Indicate that the asset is not an alias
  };

  // Create a record for the set_asset_service_properties call
  let updateRecord = {key = assetKey, properties = newProperties};

  // Call the 'set_asset_service_properties' method on the FileCanister
  let response = await FileCanister.icrc56_set_asset_service_properties([updateRecord]);

  // Handle the response based on the result
  switch (response[0]) {
    case (updatedProperties) {
      assert (updatedProperties.max_age == ?3600);
      Debug.print("Asset properties have been updated successfully.");
    };
    case (error) {
      Debug.print("Failed to update asset properties: " # error);
    };
  };
```

#### icrc56_certified_tree

##### Summary
The `icrc56_certified_tree` method provides a mechanism to retrieve the current certified state of the canister's file system. This certification process ensures the integrity and authenticity of the data stored within the canister.

##### Function Signature
```candid
// Retrieves the certified state tree of the file system.
icrc56_certified_tree : () -> async (CertifiedTree) query;
```

##### Pre-conditions
- There are no specific pre-conditions for this method as it does not perform any state-altering operations or expose sensitive data.

##### Post-conditions
- The method returns a `CertifiedTree` object that provides a verifiable and certified representation of the canister's current file system state.
- The response SHOULD include a certificate which can be used to verify the authenticity of the data against the canister's public key.

#### Implementor Notes

The `icrc56_certified_tree` method is essential for providing assurances about the canister file system's data integrity. It enables users to verify the authenticity of the data they retrieve from the canister, providing a layer of trust in the file system's operation.

#### icrc56_certify_hash

##### Summary
The `icrc56_certify_hash` function is used to verify the presence of an asset by its hash within the file system. This function is crucial in confirming the integrity and existence of an asset, which is particularly useful for outside entities that need to validate assets against the file system without direct access.

##### Function Signature
```candid
// Returns boolean indicating if the hash is part of the file system and a vector of paths where the file could be found.
icrc56_certify_hash : (hash: blob) -> async (bool, opt vec AssetKey) query;
```

##### Pre-conditions
- The provided `hash` MUST be a valid SHA-256 hash value of an existing asset.

##### Post-conditions
- If the `hash` corresponds to any asset within the file system, the function returns `true` along with a vector of `AssetKey` providing the paths to the asset(s).
- If the `hash` does not correspond to any asset within the file system, the function returns `false`.

##### Example Use Case in Motoko
```motoko

// Define the SHA-256 hash of the asset we want to verify
let assetHash = ...; // SHA-256 hash as blob

// Call the icrc56_certify_hash function of the FileCanister
let (found, paths) = await FileCanister.icrc56_certify_hash(assetHash);

// Handle the result
if (found) {
    // Asset with the given hash exists in the file system
    // Output the paths where the asset can be found
    paths.iterate( path -> Debug.print("Asset found at path: " # path) );
} else {
    // Asset with the given hash does not exist in the file system
    Debug.print("Asset not found");
}
```



### icrc56_copy

#### Summary
The `icrc56_copy` method allows for duplicating an asset within the canister's file system from a source path to a destination path. It creates an identical copy of the source asset at the new location, preserving all properties, permissions, and content.

#### Function Signature
```candid
// Duplicates an asset from the source path to the destination path.
icrc56_copy : (CopyRequest) -> async (CopyResponse) update;
```

#### Pre-conditions
1. Caller MUST have `Read` Asset Permissions and `Write` permissions on the source asset.
2. Caller MUST have `Commit` staging permissions permission.
3. The source asset specified by `CopyRequest.from` MUST exist.
4. The destination path specified by `CopyRequest.to` MUST NOT already have an asset with the same name as the source asset unless overwrite is set to true.

#### Post-conditions
1. A new asset is created at `CopyRequest.to` that is an exact copy of the source asset found at `CopyRequest.from`.
2. The operation generates a `CopyResponse` which could be a transaction index or an error.
3. The certification tree is up to date and containing the new asset.

#### Arguments
- `CopyRequest`: A record that contains `from` (the current path of the file) and `to` (the new path where the file should be copied).

#### Response
- `CopyResponse`: Contains details about the outcome of the operation such as transaction index or error information.

#### Example Use Case in Motoko
```motoko

// Define the source and destination paths to copy the asset
let srcPath = "images/profile.png";
let dstPath = "backup/profile_copy.png";

// Call the icrc56_copy function with the copy request
let response = await FileCanister.icrc56_copy({
  from = srcPath;
  to = dstPath;
  overwrite = false;
});

// Handle the response
switch (response) {
    case (#Ok(trxIndex)) {
        // Copy was successful, the asset now exists at the destination path
        Debug.print("Asset copied successfully. Transaction Index: " # Nat.toText(trxIndex));
    };
    case (#Err(error)) {
        // Handle error case
        Debug.print("Asset copy failed: " # error);
    };
};
```

#### icrc56_rename

#### Summary
The `icrc56_rename` method enables renaming or moving an asset from an old path to a new path within the canister file system. It is essential for organizing file structures, updating resource locations, or changing asset names.

#### Function Signature
```candid
// Renames or moves an asset from the old path to the new path.
icrc56_rename : (RenameRequest) -> async (RenameResponse) update;
```

#### Pre-conditions
1. Caller MUST have `Write` permissions for the asset being renamed.
2. The asset at `RenameRequest.from` MUST exist.
3. No asset should exist at `RenameRequest.to` unless overwrite is set to true;

#### Post-conditions
1. The asset previously located at `RenameRequest.from` is now located at `RenameRequest.to`.
2. All properties and permissions of the asset remain unchanged except for the updated path.
3. A `RenameResponse` is returned containing a transaction index or an error message.
4. The Certification tree is updated with the new file paths.

#### Arguments
- `RenameRequest`: A record comprising `from` (the current path) and `to` (the new path of the asset).

#### Response
- `RenameResponse`: May indicate success with a transaction index or failure with an error message.

#### Example Use Case in Motoko
```motoko

// Define the old and new paths for the asset
let oldPath = "images/photo.jpg";
let newPath = "images/renamed_photo.jpg";

// Call the icrc56_rename function with the rename request
let response = await FileCanister.icrc56_rename({
  from = oldPath;
  to = newPath;
});

// Handle the response
switch (response) {
    case (#Ok(trxIndex)) {
        // Rename was successful, the asset now exists at the new path
        Debug.print("Asset renamed successfully. Transaction Index: " # Nat.toText(trxIndex));
    };
    case (#Err(error)) {
        // Handle error case
        Debug.print("Asset rename failed: " # error);
    };
};
```

#### Additional Considerations:

- Directories cannot be copied. Or renamed. All files must be referenced.
- Error handling should account for edge cases such as non-existent source paths, pre-existing assets at the destination path, lack of permissions, and system-related errors (full disk, read-only state, etc.).
- Atomicity and consistency should be ensured during the rename operation to prevent system states where an asset is neither at the old nor the new path or exists at both.

#### icrc56_list

##### Summary
The `icrc56_list` method is designed to list all files and directories within a specified directory path in the Internet Computer's Canister File System as per the ICRC-56 standard. This method is beneficial for exploring the file structure of a canister and retrieving specific file details.

##### Function Signature
```candid
// Retrieves a list of items within a directory path on the file server.
icrc56_list : (arg : ListRequest) -> async (vec ListResponse) query;
```

##### Pre-conditions
- `arg.path` MUST correspond to an existing directory within the canister's file system.
- If `arg.recursive` is set to `true`, the system SHOULD verify that the requested operation does not violate any permissions or restrictions set for subdirectories and their contents.

##### Post-conditions
- The method SHOULD return a vector of `ListResponse` items that represent each file or directory within the specified path.
- If `arg.recursive` is `true`, the method SHOULD include items from subdirectories in the response.
- The method SHOULD apply any filter specified via `arg.name_filter` and `arg.size_filter` to the list results.
- If `arg.details` is `true`, additional details such as encoding and file metadata SHOULD be included for each item in the response.
- If directory listings are prohibited (`arg.dir` is `false`), directories SHOULD NOT appear in the response, only files will be listed.

##### Arguments
- `arg: ListRequest`: Structured argument specifying the path, flags, and filters for the listing operation.

##### Response
- `vec ListResponse`: A vector containing responses for each item in the list. Items that meet the criteria specified in `ListRequest` are expected to be included in this vector.

##### Errors
- Potential errors include invalid path, unauthorized access, request size limitations, and internal server errors that may occur during the operation.

##### Example Use Case in Motoko
```motoko
// Define a directory path and list request parameters
let directoryPath = "/documents/";
let listRequest = {
  path = directoryPath;
  recursive = true; // List all items recursively
  name_filter = null; // No specific name filter applied
  size_filter = null; // No size filter applied
  details = true; // Request additional details
  dir = true; // Include directories in the listing
};

// Call the icrc56_list method to obtain the file list
let listResult = await FileCanister.icrc56_list(listRequest);

// Process the response to extract file details
for (item in listResult) {
  // ... handle each listed item, process file details, etc.
}
```

### Additional Methods for Handling Metadata and Permissions


### icrc56_refresh_group_request

#### Summary
The `icrc56_refresh_group_request` method allows for initiating a request to a group canister, requesting it to send updated group lists. This mechanism ensures that group permission sets within the file system are kept current.

#### Function Signature
```candid
// Requests a group canister to refresh the group list.
icrc56_refresh_group_request : (namespace: text) -> async () update;
```

#### Pre-conditions
1. The caller SHOULD possess the authority to manage group permissions within the file system, typically having 'ManagePermissions' rights.
2. The `namespace` provided MUST correspond to a recognizable namespace within the file system that addresses a specific group canister.

#### Post-conditions
1. A group refresh request is issued to the group canister associated with the provided `namespace`.
2. The group canister is expected to respond with an up-to-date group list, typically via a separate method invocation.

#### Arguments
- `namespace`: The namespace under which the group is registered, used to target the related group canister.

#### Example Use Case in Motoko (Annotated)
```motoko
// Assume an administrative function within a front-end canister or client
public func refreshGroupPermissions(namespace: Text) : async () {
    // Call the file system's refresh group request method with the specified namespace
    await FileSystemCanister.icrc56_refresh_group_request(namespace);

    // It's a one-shot call that doesn't return a value but triggers a group update
    // Optionally, handle events or state changes upon receipt of the updated group list
}
```

#### icrc56_refresh_group_response

#### Summary
The `icrc56_refresh_group_response` method is a callback mechanism for group canisters to provide updated group information in response to a refresh request. It is essential for maintaining correct and current permission sets within the file system.

#### Function Signature
```candid
// Updates the canister file system with the refreshed group list from the group canister.
icrc56_refresh_group_response : (refreshed_group: AssetPermissionList, namespace: text) -> async () update;
```

#### Pre-conditions
1. The group canister SHOULD verify its own authority to update groups within the namespace, ensuring that only valid updates are made.
2. The `namespace` MUST be a valid identifier within the file system that has an existing association with the responding group canister.

#### Post-conditions
1. The file system updates its internal group permission mappings with the `refreshed_group` data provided.
2. Future file system operations take into account the updated group permissions.

#### Arguments
- `refreshed_group`: An updated list of `AssetPermission` values representing the new state of the group permissions.
- `namespace`: The namespace that is associated with the group and its permissions.

#### Example Use Case in Motoko (Annotated)
```motoko
// Example within a group canister responding to a refresh request
public shared(msg) func sendUpdatedGroupList(namespace: Namespace, updatedList: AssetPermissionList) : async () {
    // Call the file system canister to update the group permissions
    await FileSystemCanister.icrc56_refresh_group_response(updatedList, namespace);

    // The file system canister updates the group permissions accordingly
    // No return value, but the update is completed internally within the file system canister
}
```

## icrc56_metadata

### Summary
The `icrc56_metadata` query method provides metadata about the canister's file system configuration and capabilities. This metadata information is crucial for consumers to understand the limitations and features provided by the canister file system.

### Function Signature
```candid
// Retrieves metadata information about the canister file system.
icrc56_metadata : () -> async (vec record { text; Value }) query;
```

### Pre-conditions
- None.

### Post-conditions
- The canister returns a vector of records, each containing a text identifier and a `Value`.

### Metadata Attributes
The response typically includes the following attributes, but is not limited to:
- `icrc56:max_batches`: The maximum number of open batches the file system can handle simultaneously.
- `icrc56:max_chunks`: The maximum number of chunks an asset can contain.
- `icrc56:max_bytes`: The maximum number of bytes each chunk can contain.
- `icrc56:max_query_batch_size`: The maximum batch size for query calls supported by the ledger.
- `icrc56:max_update_batch_size`: The maximum batch size for update calls supported by the ledger.
- `icrc56:default_take_value`: The default pagination size for query results.
- `icrc56:max_take_value`: The maximum pagination size for query results.
- Other custom configuration parameters as defined by the implementor.

### Example Use Case in Motoko (Annotated)
```motoko
// Import necessary modules
import Debug "mo:base/Debug";
import FileCanister "canister:FileCanister";

// Function to fetch and display file system metadata
public func fetchFileSystemMetadata() : async () {
  // Call the icrc56_metadata method to obtain the metadata
  let metadata = await FileCanister.icrc56_metadata();

  // Iterate through the metadata records and display
  for ({key, value} in metadata) {
    Debug.print("Metadata - Key: " # key # ", Value: " # debug_show(value));
  }
}
```

### Staging Permissions

ICRC-56 itself does not manage canister staging permissions. Whereas various methods allow for actions such as asset creation, updating content, and managing batches, the standard implementor SHOULD implement a robust security system. It is not within the purview of ICRC-56 to define the specifics of such a security model; rather, it provides the necessary hooks and functions for a security layer to be built on top.

A comprehensive system should ensure the following:

- **Authorization**: Establish and enforce rules that determine what authenticated users and services are allowed to do within the canister file system. This typically involves managing permissions and access control lists (ACLs).
- **Asset Protection**: Safeguard assets from unauthorized access and modifications. This includes ensuring the integrity and confidentiality of the stored assets.

#### Handling Permissions

A canister operating under ICRC-56 SHOLD implement, at a minimum, the following methods related to permissions:

- `authorize(other: Principal)`: Grant a specific principal the ability to commit assets.
- `deauthorize(other: Principal)`: Revoke a principal's existing commit permission.
- `list_authorized()`: List all principals with commit permissions.

### Asset Permissions

#### Overview

The asset permission system within the ICRC-56 standard governs access control to various operations related to filesystem assets. It is designed to provide granular control over who can view, modify, list, update permissions, or delete files and directories hosted by a canister implementing the ICRC-56 standard.

#### Relation to File Serving

Asset permissions are closely intertwined with how files are served. An asset's permissions determine which principals (users or other canisters) are authorized to interact with the asset in specific ways. Each type of interaction—be it reading, writing, or listing directory contents—may have its own set of associated permissions. By setting appropriate permissions, the implementor can control access to the filesystem and safeguard against unauthorized manipulation.

#### WRITE Permission

The WRITE permission indicates whether a principal has the ability to modify an asset's content. Implementors MUST treat the WRITE permission as a mandatory check before allowing any changes to an asset's content or properties. If a principal does not possess the WRITE permission for a given asset, attempts to modify that asset should be rejected, and appropriate error handling should be performed.

#### PERMISSIONS Permission

The PERMISSIONS permission extends beyond the individual principal's abilities, allowing specified principals to manage the permissions of an asset. In addition to any authorized users at the canister level, anyone granted the PERMISSIONS permission SHOULD be authorized to update the permissions of the target asset. Managing these permissions includes granting or revoking various access rights to other principals.

#### READ Permission

Similar to the LIST permission, the READ permission dictates who can retrieve an asset or its metadata. Implementors should restrict reading the asset or its associated metadata to those principals with the appropriate READ permission. Principals without this permission should not be able to access the content or information about the asset.

Specifically, the following functions should not return non public data to query requests not made from an authorized principal if the READ permission is set:

icrc56_get_asset_service_properties
icrc56_get
icrc56_list
icrc56_retrieve

# ICRC-3 operations

The ICRC-3 operations (op types) within the Canister File System Canister that need to be emitted when users perform various file operations includes, but may not be limited to, the following:

1. `create_file`: Issued when creating a new file within the filesystem.
2. `delete_file`: Issued when deleting a file from the filesystem.
3. `update_file`: Issued when updating the contents of an existing file.
4. `rename_file`: Issued when renaming a file.
5. `move_file`: Issued when moving a file from one directory to another.
6. `copy_file`: Issued when copying a file to another location.
7. `change_stage_permission`: Issued when changing the staging permissions associated a user.
12. `change_access_permission`: Issued when changing the permissions associated with a file or directory.
16. `mount_storage_canister`: Issued when mounting an additional storage canister to the filesystem.
21. `commit_file`: Issued when a batch of file operations is committed atomically.





