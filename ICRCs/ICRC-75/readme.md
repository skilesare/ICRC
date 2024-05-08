|ICRC|Title|Author|Discussions|Status|Type|Category|Created|
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|75|Minimal Membership Standard|Austin Fatheree (@skilesare), @ava-vs, Matt Harmon, Lachlan Witham, Zhenya Usenko, Byron Becker @byronbecker, Celletti @gektek|https://github.com/dfinity/ICRC/issues/75|Draft|Standards Track||2024-05-08|

# ICRC-75: Minimal Membership Standard

The ICRC-75 standard defines a robust framework for managing composable identity lists within the Internet Computer ecosystem. This standard provides the necessary specifications for creating, managing, and utilizing identity lists that can be composed of both individual identities and other lists, thereby allowing complex and dynamic group structures suitable for a variety of applications.

The ability to manage identities in a composable manner is crucial for numerous decentralized applications on the Internet Computer, particularly those that require sophisticated access control mechanisms or group-based interactions. For instance, decentralized autonomous organizations (DAOs), collaborative platforms, and multi-tier membership programs can all benefit from the flexibility and the management capabilities offered by ICRC-75.

## Use Cases

1. **Decentralized Organizations and Governance**: DAOs can utilize ICRC-75 to manage memberships and sub-group structures dynamically. This includes creating different tiers of membership with specific permissions or voting rights, and easily updating the membership criteria as the organization evolves.

2. **Access Control for Collaborative Projects**: In environments where resources or information need to be segmented and accessed selectively, ICRC-75 can be used to manage access permissions efficiently. For example, a research project might have multiple teams that require access to specific subsets of data or tools, managed dynamically as the project develops.

3. **Subscription-based Services**: Businesses that operate on subscription models can manage customer lists and their corresponding access rights to services or content. ICRC-75 makes it trivial to upgrade or downgrade memberships, add promotional memberships, and integrate diverse subscription models within the same system.

4. **Educational Platforms and Credential Systems**: Educational institutions can manage lists of students, faculty, and courses, where each list might have different permissions for access to materials like research papers, assignments, and collaborative tools.

5. **Event Management**: For events with multiple sessions or areas, organizers can control and oversee access based on participant lists, dynamically modifying them to allow for changes in participant status or session availability.

## Privacy Considerations

In the design and implementation of ICRC-75, privacy concerns have been explicitly recognized, particularly due to the transparent nature of list memberships on the Internet Computer. The following points outline the approach taken regarding privacy within this standard:

1. **No Additional Privacy Protections**:
   - ICRC-75 does not incorporate mechanisms inherently to shield or obscure user identities in the lists. Therefore, identities (Principals) added to any list are openly visible by default to anyone granted the respective read access.
   - As Principals circulate in the Internet Computer ecosystem, they can, by various analytical means, be tracked or associated across different services or canisters. Hence, stakeholders should be aware that using ICRC-75 could potentially expose users to identity correlation risks.

2. **Recommendation for Enhanced Privacy**:
   - The Working Group acknowledges the limitations in privacy with the current design and suggests further exploration into extensions that would allow for privacy-enhanced operations. One such proposed concept involves users providing a "shielded" identity — a pseudonymous or anonymized version of their Principal, which can still interact within the list environments without revealing the true Principal.
   - These shielded identities could potentially interact with a privacy-focused authentication service, such as the Internet Identity, to confirm membership without divulging the actual Principal to the list manager or other entities. The key principle would be creating an indirect link between the user's real identity and list membership, managed through cryptographic proofs or similar methodologies.

3. **Potential Extensions for Privacy-Preserving Features**:
   - Developers and stakeholders are motivated to contribute to discussions regarding extensions that would incorporate Anonymous Credentials or other cryptographic techniques that can prove list membership without revealing the identity.
   - Such techniques could include Zero Knowledge Proofs (ZKP) or similar protocols, where a user proves their membership in a group to another party without revealing which specific member they are.

4. **Use-Case Based Recommendations**:
   - For applications where privacy is a critical concern, it's recommended to utilize ICRC-75 only with added privacy-preserving layers or potentially different mechanisms altogether that inherently support anonymous or pseudonymous participation.
   - In contexts where users must be ensured of anonymity and non-traceability, alternatives to ICRC-75 should be considered, or additional privacy-preserving features should be demanded before integration.

These privacy considerations emphasize the importance of contextual implementation. While ICRC-75 provides fundamental functionalities necessary for managing membership data, privacy-sensitive applications may necessitate additional layers or different standards altogether to meet their specific privacy requirements.

## Data Representations

This section defines the core data types and structures used within ICRC-75 for representing identities, lists, and permissions associated with the management of composable identity lists on the Internet Computer.

### Identity

An identity in ICRC-75 is associated with an individual or entity capable of interacting within the ecosystem. The primary representation of an identity is a `Principal`, which is a unique identifier assigned to users and canisters on the Internet Computer.

```candid "Type definitions" +=
type Identity = Principal;
```

The `Principal` is a type intrinsic to the Internet Computer, providing a secure and verifiable way to represent identities. The identities are text-encoded and include a checksum for integrity verification.

### List

A list in ICRC-75 represents a collection of identities and potentially other nested lists, enabling the composition of complex group structures. Each list is uniquely identified by a textual name within a namespace, facilitating organized management and referencing.

```candid "Type definitions" +=
type List : text;
```

Lists can include members that are direct identities or other lists, enabling hierarchical groupings. This composability supports the creation of extensive and flexible group structures, such as combining multiple subgroups into a larger collective group.

### Permissions

Permissions in ICRC-75 define the actions that identities or lists can perform on other lists. The permissions are categorized into various types, each representing a specific capability:

```candid "Type definitions" +=
type Permission = Variant {
    Admin;        // Full administrative rights, including managing permissions and sublists.
    Read;         // Permission to view the list and its members.
    Write;        // Ability to modify the list, add or remove members.
    Permissions;  // Rights to modify the permissions of other identities in the list.
};
```

- **Admin**: Carries the rights to perform any administrative tasks on the list such as renaming, deleting, or configuring permissions.
- **Read**: Allows the viewing of the list's contents, enabling identities with this permission to see which other identities or lists are members.
- **Write**: Grants the ability to add or remove identities and nested lists, as well as to modify members within the list.
- **Permissions**: Entrusted with managing who can or cannot modify the permissions associated with the list, adding an additional layer of administrative control.

Through these permissions, ICRC-75 can effectively manage access and actions that can be performed by various identities across different lists within the ecosystem.

This section defines the necessary data types and structures used within ICRC-75 for managing composable identity lists.

### Types for querying lists

#### **`ListItem`**:
   - A `variant` that can hold either an `Identity` or a `List`. This structure allows each list item to be either a direct reference to an identity (a principal on the Internet Computer) or another list (effectively creating nested or hierarchical lists).


```candid "Type definitions" +=
type ListItem = variant {
    Identity: Identity;
    List: List;
};
```

#### **`AuthorizedRequestItem`**:
   - A `record` combining a `List` and an `Identity`. Represents a request to check if specific identities are authorized in the context of specified lists. This aids in efficient batch processing of access checks.

```candid "Type definitions" +=
type AuthorizedRequestItem = record { List; Identity; };
```

#### **`AuthorizedResponse`**:
   - A vector of type `Bool`. It returns a series of Boolean values that correspond to the authorization check result of each item in the `AuthorizedRequestItem`. True means authorized; false means not authorized.

```candid "Type definitions" +=
type AuthorizedResponse = vec Bool;
```

#### **`IdentitiesResponse`** and **`ListsResponse`**:
   - Both are simple vectors containing either `Identity` or `List` items, respectively. Used to return results in queries for members of a list (`IdentitiesResponse`) or sublists (`ListsResponse`).

```candid  "Type definitions" +=
type IdentitiesResponse = vec Identity;
type ListsResponse = vec List;
```

### Types for managing lists

The types defined to manage the lists inside the ICRC-75 standard are critical for understanding how identities and lists are structured, how they interact, and how permissions are managed. Below is an explanation of each type:

#### **`ManageListPropertyRequestItem`**:
   - A comprehensive `variant` for various list-management actions such as managing membership(`Add`,`Remove`), renaming a list (`Rename`), deleting a list (`Delete`), or changing permissions (`ChangePermissions`). The `ChangePermissions` variant is particularly detailed, allowing the addition or removal of permissions for reading, writing, administrating, or managing permissions of the list for specific `ListItem`s.

```candid  "Type definitions" +=
type ManageListPropertyRequestItem = variant {
  Create : record {
    name : text;
    admin : ?ListItem;
    metadata : ?Map;
  };
  Rename : text; 
  Delete;
  Metadata: {
    key : text;
    value : opt Value
  }; 
  Add: ListItem; 
  Remove: List;
  ChangePermissions : variant {
    read : variant{
      all;
      add : ListItem;
      remove : ListItem;
    };
    write : variant{
      add : ListItem;
      remove : ListItem;
    };
    admin : variant{
      add : ListItem;
      remove : ListItem;
    };
    permissions : variant{
      add : ListItem;
      remove : ListItem;
    };
  } 
};

```

##### Nested Permission Details:

The `ChangePermissions` in `ManageListPropertyRequestItem` offers granular controls divided among various scopes like `read`, `write`, `admin`, and `permissions`. Each scope permits adding or removing permissions via adding or removing `ListItem`s (either identities or sublists) that can perform associated actions.

- `read all`: A special directive under `read` permissions allowing universal read access if set.
- `add` and `remove`: Allow the modification of lists or identities that have specific permissions for detailed access control. 


#### `ManageListPropertyResult`**:
   - Encapsulate a common pattern where an operation can result in success or failure:
     - `Ok`: Indicates success and holds a `TransactionID` which can be used for auditing or tracking.
     - `Err`: Represents an error and holds an error struct that can explain what went wrong.

```candid  "Type definitions" +=

type ManageListPropertyResult = variant {
  Ok : nat;
  Err : ManageListPropertyError;
}

type ManageListPropertyError = variant {
  Unauthorized;
  Other : record{
    code : nat;
    message : text;
  };
  ListNotFound; //could not find the referenced list
  ListItemFound; //the requested List Item was not found to modify
  CircularReference : text; //should report the list where the circular reference was discovered.
  NameReserved;
}

```

### Canister Management

```candid  "Type definitions" +=
type ManageRequestItem = variant { 
  UpdateDefaultTake : nat;
  UpdateMaxTake : nat;
  UpdatePermittedDrift : nat;
  UpdateTxWindow : nat;
  UpdateDefaultExpires : nat;
  Metadata : {
    key : text;
    value : ?Value;
  }
};

type ManageResult = ?(variant {
  Ok: TransactionID
  Err: ManageError;
});

type ManageError = ?(variant {
  Unauthorized;
  Other : record{
    code : nat;
    message : text;
  };
});

```

### Data Structure for Identity Tokens

Identity tokens within the ICRC-75 standard play a crucial role as cryptographic proofs of membership for entities participating within any given list. These tokens enable identities to establish their association rights with respect to various resources or services managed on the Internet Computer.

#### Definition

```candid  "Type definitions" +=
type IdentityToken = record {
    authority: blob;      // Principal of the canister issuing the token.
    namespace: Text;      // The list namespace to which the token pertains.
    issued: Nat;          // Timestamp of when the token was issued.
    expires: Nat;         // Timestamp of when the token expires.
    member: blob;         // Principal of the user to whom the token is issued.
    nonce: Nat;           // A unique nonce to ensure the freshness of the token.
};

type IdentityCertificate = record {
    token: IdentityToken;      
    witness: Witness;      
    certificate: blob;      
};

  /// The type of witnesses. This corresponds to the `HashTree` in the Interface
  /// Specification of the Internet Computer
  type Witness = variant {
    #empty;
    #pruned : blob;
    #fork : (Witness, Witness);
    #labeled : (Blob, Witness);
    #leaf : blob;
  };
```

#### Description

- **authority**: This field holds the principal identifier of the canister that issues the identity token. It acts as the trusted authority that validates the identity's membership within the specified list.

- **namespace**: A textual identifier representing the specific list or domain within the standard for which the token is applicable. This allows for distinguishing different groups or access levels under the same authority.

- **issued and expires**: These fields mark the validity timeframe of the token, detailing precisely when the token becomes active and when it ceases to be valid. It is crucial for temporal verification, ensuring tokens are used within their designated periods.

- **member**: Contains the principal identifier of the entity that possesses the token. This field is essential for linking the token to a specific member within the list, enabling their identification and authentication.

- **nonce**: A unique numerical value used once to guard against replay attacks. This ensures that each token is uniquely tailored for a single use and cannot be maliciously reused.

### Usage

Identity tokens are used to provide a verifiable mechanism for identities to prove their membership within specific lists when interacting with other canisters or services. When an identity needs to interact or access a resource, it presents its token; the resource can then validate this token by checking its integrity and authenticity against the issuing authority’s public records. This system enables decentralized and secure verification of memberships without constant online checks with the authority canister, thereby reducing overhead and enhancing performance across the network.

### Security and Verification

To ensure the security of identity tokens, the issuing canister hashes the token records to a Merkle tree and the subnet signs the root. During verification:

1. **Record Submission**: The service demanding proof of membership requires the submission of the token record.
2. **Witness Provision**: Accompanying the record, a witness (part of the Merkle tree) is also provided, confirming the particular entry’s validity lined to the signed root.
3. **Certificate Checking**: Lastly, a certificate signed by the subnet and produced by the canister, which includes the Merkle root, is verified to ensure that the witness and the record correspond to the signed state of the issuing canister.

By using cryptographic proofs and decentralized verification methods, ICRC-75 ensures that identity tokens are both secure and efficient in managing identity verifications across the Internet Computer ecosystem.

### Generally-Applicable Specification

We next outline general aspects of the specification and behavior of query and update calls defined in this standard. Those general aspects are not repeated with the specification of every method but are specified once for all query and update calls in this section.

#### Batch Update Methods

Please reference [ICRC-7](https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.md#batch-update-methods) for information about the approach to Batch update Methods.

#### Batch Query Methods

Please reference [ICRC-7](https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.md#batch-query-methods) for information about the approach to Batch update Methods.

#### Error Handling

Please reference [ICRC-7](https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.md#error-handling) for information about the approach to Batch update Methods.

#### Other Aspects

Please reference [ICRC-7](https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.md#other-aspects) for information about the approach to Batch update Methods.

## Function Definitions

### ICRC-75 Standard Function Categories

Functions within the ICRC-75 standard are categorized into specific groups based on their operational functionalities. This categorization helps in organizing the methods according to their purposes such as list management, identity verification, membership querying, etc. Here’s the detailed segregation:

#### Management Update Functions

These functions enable the dynamic management and update of lists according to specified criteria by authorized users. They facilitate the central administration tasks involved in the identity list structure.

##### icrc_75_manage

This function provides a generalized interface for managing various properties and behaviors within lists. Administrators can invoke this function to submit batches of management requests, which could range from adding new identities to adjusting configuration settings for the list.

```candid "Methods" +=
// Add or remove identities and sublists in a list
icrc_75_manage: (vec ManageRequest) -> async vec ManageResult;
```

The only users who can call this function should be members of the admin list as reported by the canister icrc_75_metadata endpoint.

##### icrc_75_manage_list_properties

Focused on manipulating the direct properties of a list, such as its membership, renaming or deleting it, this function serves administrative purposes. It can be used to enforce changes in the list’s metadata or structure, adhering to governance rules or updates in organizational structure.

```candid  "Methods" +=
// Manage list itself (rename, delete)
icrc_75_manage_list_properties: (vec { record { 
  list: List,
  memo: blob,
  created_at_time: nat
  action: ManageListPropertyRequestItem 
}}) -> async vec ManageListPropertyResult;
```

#### Management Query Functions

These functions facilitate the retrieval of information about lists and their administrative settings without modifying any existing data. This function category is crucial for transparency, audit, and reporting purposes.

##### icrc_75_metadata

Returns important metadata about the canister and its support and feature set for ICRC-75.

```candid  "Methods" +=

icrc_75_metadata: () -> query async Map;
```

Values that are enshrined by this standard are:

icrc75:logo - #Text - url or data url of the logo for the canister.
icrc75:permittedDrift - #Nat - permitted drift
icrc75:txWindow - #Nat - transaction window
icrc75:defaultExpires - #Nat - transaction window
icrc75:defaultTake - #Nat - default take value if not provided in queries
icrc75:maxTake - #Nat - maximum take value allowed in queries
icrc75:adminList - #Text - list used for admins of the canister

##### icrc_75_get_lists

Allows retrieval of lists in a pageable fashion, making it scalable for environments with large numbers of lists. It can be used to browse through lists based on pagination settings.

```candid  "Methods" +=
// Retrieve lists, pageable
icrc_75_get_lists: (prev: opt List, take: opt nat) -> query async vec List;
```

##### icrc_75_get_list_members_admin

Retrieve administrative details about list members, also in a pageable manner. It is used predominantly by administrators to manage and view list compositions and settings effectively.

```candid  "Methods" +=
// Retrieve lists, pageable
icrc_75_get_list_members_admin: (list: List, prev: opt ListItem, take: opt nat) -> query async vec ListItem;
```

The server should return the lists in alphabetic order first followed by the principals in a deterministic order.

#### List Queries

These functions are used to fetch detailed information regarding the members within the lists and the list structures themselves. They are vital for validating membership and understanding the hierarchical setup of nested lists.

##### icrc_75_get_lists_metadata

Allows retrieval of metadata for a list.

```candid  "Methods" +=
// Retrieve lists, pageable
icrc_75_get_list_metadata: (lists: vec List, prev: opt List, take: opt nat) -> query async vec Map;
```

Values that are enshrined by this standard are:

icrc75:list:logo - #Text - URL or data URL of the logo for the canister.
icrc75:list:defaultExpires - #Nat - overrides the default expires at the canister level if present
icrc75:list:lastModified - #Nat - Last date that the list was modified. UTC Nanoseconds
icrc75:list:created - #Nat - Create date that the list was created. UTC Nanoseconds
icrc75:list:name - #Text - Readable name of the list
icrc75:list:description - #Text - Readable description of the list
icrc75:list:name:{Lang Code} - #Text - Readable name of the list
icrc75:list:description:{Lang Code} - #Text - Readable description of the list

Use ISO 639-1 language code if specifying multiple Names and descriptions.

##### icrc_75_get_list_lists

Facilitates the retrieval of sublists from a specific list, helping in understanding and navigating the structure of nested lists. Supports paging to manage larger structures effectively.

```candid  "Methods" +=
// Retrieve sublists from a list, pageable
icrc_75_get_list_lists: (list: List, prev: opt List, take: opt nat) -> query async vec List;
```

Lists should be returned in alphabetic order.

##### icrc_75_get_list_members

Retrieves identities from a list in a pageable manner. This is crucial for operations requiring validation of membership and for interfaces that need to display list compositions to users.

The list should be retrieved as a flattened list of the members of the list, including the members in lists that are included in the list.

```candid  "Methods" +=
// Retrieve identities from a list, pageable
icrc_75_get_list_members: (list: List, prev: opt Identity, take: opt nat) -> query async vec Identity;
```

Principals should be returned in deterministic order.

##### icrc_75_is_member

Checks if specified identities are members of the lists they are queried against. This is a crucial function for validating access and permissions within the ecosystem, ensuring that operations are performed by authorized identities.

```candid  "Methods" +=
// Check membership of identities within lists
icrc_75_is_member: (vec (Identity, List)) -> query async vec bool;
```

#### Token Management Functions

These functions manage the lifecycle of membership tokens, which are used as a verifiable means to assert membership in lists, crucial for interactions across decentralized services.

##### icrc_75_request_token

Initiates a request for a membership token, representing an asynchronous operation where the token's preparation is handled in the background.

If expires is not set the canister should use the default expires in nanoseconds.

```candid  "Methods" +=
// Request a membership token for a list
icrc_75_request_token: (List, expires: ?nat) -> async bool;
```

##### icrc_75_revoke_token

Revokes a token by adding it to the ICRC3 transaction log and attempting to emit an event if available.

Note: Token revocation will not be universal unless the accepting system subscribes to the revocation event, and even then, may experience a delay in delivery.

```candid  "Methods" +=
// Request a membership token for a list
icrc_75_revoke_token: (List, expires: ?nat) -> async bool;
```

##### icrc_75_retrieve_token

Retrieves a previously requested membership token, providing a crucial link in ensuring that tokens are delivered securely and can be used by the requester to verify membership.

```candid  "Methods" +=
// Retrieve a prepared membership token for a list
icrc_75_retrieve_token: (list: List) -> query async IdentityCertificate;
```

### icrc10_supported_standards

An implementation of ICRC-75 MUST implement the method `icrc10_supported_standards` as put forth in ICRC-10.

The result of the call MUST always have at least the following entries:

```candid
record { name = "ICRC-75"; url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-75"; }
record { name = "ICRC-10"; url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-10"; }
```


## Generic ICRC-7 Block Schema

An ICRC-75 block is defined as follows:
1. its `btype` field MUST be set to the op name that starts with `75`
2. it MUST contain a field `ts: Nat` which is the timestamp of when the block was added to the Ledger
3. it MUST contain a field `tx`, which
    1. MAY contain a field `memo: blob` if specified by the user
    2. MAY contain a field `ts: Nat` if the user sets the `created_at_time` field in the request.

The `tx` field contains the transaction data as provided by the caller and is further refined for each the different update calls as specified below.

The block schemas for ICRC-75 are designed to record and track changes relating to list and identity management on the Internet Computer. Following is a detailed specification of each block type required for ICRC-75:

### Change Block Schema

1. **`btype` field**: MUST be set to `"75change"`
2. **`tx` field**:
   1. MUST contain a field `property: Text` identifying the property affected. Should correspond to the setting name in the canister metadata.
   2. MUST contain a field `value: Value` identifying the value the item is set to.
   2. MUST contain `caller: Identity ` specifying the Principal ID of the caller.

### List Creation Block Schema

1. **`btype` field**: MUST be set to `"75listCreate"`
2. **`tx` field**:
   1. MUST contain a field `listId: Text` as the identifier for the newly created list.
   2. MUST contain a field `caller: Identity` as the Principal ID of the creator.
   3. MAY contain a field `initialAdmin: Identity - blob or List - text` containing initial admin of the list.
   3. MAY contain a field `initialMetadata: Map` containing initial list metadata.

### List Delete Block Schema

1. **`btype` field**: MUST be set to `"75listDelete"`
2. **`tx` field**:
   1. MUST contain a field `listId: Text` as the identifier for the newly created list.
   2. MUST contain a field `caller: Identity` as the Principal ID of the creator.

### List Rename Block Schema

1. **`btype` field**: MUST be set to `"75listRename"`
2. **`tx` field**:
   1. MUST contain a field `listId: Text` as the identifier for the newly created list.
   2. MUST contain a field `caller: Identity` as the Principal ID of the creator.
   3. MUST contain a field `oldListId: Text` as the identifier for the old name.
   1. MUST contain a field `newListId: Text` as the identifier for the new name.

### List Metadata Block Schema

1. **`btype` field**: MUST be set to `"75listMetadata"`
2. **`tx` field**:
   1. MUST contain a field `listId: Text` as the identifier for the newly created list.
   2. MUST contain a field `caller: Identity` as the Principal ID of the creator.
   3. MUST contain a field `property: Text` as the identifier for the key being changed.
   4. MAY contain a field `value: Text` as the new value. SHOULD be empty if the key is being removed.

### Membership Change Block Schema

1. **`btype` field**: MUST be set to `"75listMemChange"`
2. **`tx` field**:
   1. MUST contain a field `listId: Text` identifying the list affected.
   2. MUST contain `changedIdentity: Identity - blob or List - Text` specifying the Principal ID or list of the identity changed.
   3. MUST contain a field `changeType: Text` indicating "added" or "removed".
   4. MAY contain a field `caller: Identity - blob` identifying who made the change if applicable.

### Permission Change Block Schema

1. **`btype` field**: MUST be set to `"75listPermChange"`
2. **`tx` field**:
   1. MUST contain a field `list: Text` for the list where permissions are altered.
   2. MUST contain a field `targetIdentity: Identity- blob or List - text` for whose permissions have changed.
   3. MUST contain a field `permissions: Text` detailing the new permission set.
   4. MUST contain a field `changeType: Text` indicating "added" or "removed".
   5. MUST contain a field `caller: Identity - blob` identifying who made the changes.

### Token Request Block Schema

1. **`btype` field**: MUST be set to `"75token"`
2. **`tx` field**:
   1. MUST contain a field `list: Text` for the list where permissions are altered.
   2. MUST contain a field `member: Identity- blob` for who the token is being created for.
   3. MUST contain a field `nonce: Nat` detailing the nonce used.
   4. MUST contain a field `issued: Nat` indicating the start of the time the token is valid.
   5. MUST contain a field `expires: Nat` indicating the start of the time the token is valid.
   6. MUST contain a field `caller: Identity - blob` identifying who made the changes.

### Token Revoke Block Schema

1. **`btype` field**: MUST be set to `"75revoke"`
2. **`tx` field**:
   1. MUST contain a field `list: Text` for the list where permissions are altered.
   2. MUST contain a field `member: Identity- blob` for who the token is being created for.
   3. MUST contain a field `nonce: Nat` detailing the nonce used.
   6. MUST contain a field `caller: Identity - blob` identifying who made the changes.


## Transaction Deduplication

Please reference [ICRC-7](https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.md#other-aspects) for information about the approach to Transaction Deduplication.

## Security Considerations

This section highlights some selected areas crucial for security regarding the implementation of ledgers following this standard and Web applications using ledgers following this standard. Note that this is not exhaustive by any means, but rather points out a few selected important areas.

### Protection Against Denial of Service Attacks

Please reference [ICRC-7](https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.md#other-aspects) for information about the approach to Protection Against Denial of Service Attacks.

### Protection Against Web Application Attacks

Please reference [ICRC-7](https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.md#other-aspects) for information about the approach to Protection Against Web Application Attacks.

### Namespace Patterns

In the shared environment of the Internet Computer (IC), where different users and applications operate within a global namespace, it is essential to adopt a structured approach to naming. This not only avoids potential conflicts but also enhances clarity and organization of resources. Namespacing in ICRC-75 is crucial for maintaining clear and non-conflicting identifiers for lists, especially when these lists are subject to composition and reusability across different applications and services.

For clarity and to prevent naming collisions on the Internet Computer, the following namespace patterns are proposed for use within ICRC-75:

1. **Application Specific Namespaces**:
   - **Pattern**: `com.domain.app.function`
   - **Description**: This pattern is recommended for application-specific implementations where the namespace directly reflects the domain and function within that domain. The creator of the list should have control over the respective domain (i.e., DNS control over `domain.com`) to use it in the namespace.
   - **Example**: For a membership management function in an application hosted on `example.com`, the namespace might be `com.example.membership.admins`.

2. **ICRC Specific Namespaces**:
   - **Pattern**: `icrcX:domain:feature`
   - **Description**: Namespaces explicitly indicating their relevance to ICRC standards can use this pattern. This is particularly useful for lists that are meant to be recognized and potentially interacted with across various IC applications adhering to ICRC-75. This helps in differentiating standard-specific lists from application-specific data structures.
   - **Example**: For a generic admin list that should be recognized across ICRC-75 compliant canisters as having upgrade rights, the naming could be `icrc75:upgrade`.

### Recommendations for Namespace Usage

- **Uniqueness**: Always ensure that the namespace used is unique, especially if the list has the potential to interact with or be recognized by other IC applications or services.
- **Authentication and Authorization**: When possible, use namespaces that you can authenticate, particularly through DNS verification or other means that establish ownership of the domain.
- **Consistency**: Use consistent naming conventions within your namespaces to make them predictable and easier to manage, especially when dealing with complex or multiple nested lists.
- **Documentation**: Clearly document the namespaces used in your application or platform. This transparency aids other developers and users in understanding the structure and usage of lists, facilitating easier integration and interaction.

By adhering to these namespacing conventions, developers can minimize the risk of conflicts in the shared namespace environment of the Internet Computer while making their implementations clearer and more robust in the context of global and cross-application interactions.

### Integration with ICRC-72: Minimal Event Systems

ICRC-75 employs an event-driven mechanism to enable subscribers to be informed of changes in identity lists efficiently and in real-time. This integration utilizes the ICRC-72 standard, which defines a minimalistic approach to event distribution. To ensure robust and cohesive functionality, it is critical that events emitted by ICRC-75 are structured and managed in accordance with ICRC-72 specifications.

#### Event Emission Specification

Whenever a significant action is taken within the ICRC-75 system—such as creation, deletion, or modification of lists, or changes to the memberships—events should be emitted. These events allow subscribers to react to changes immediately, aiding in maintaining system integrity and coherence across the Internet Computer ecosystem.

1. **Canister-Level Events**:
   - **Event Name**: Formatted as `icrc75:{canister-id}:{btype}`
   - **Description**: This event is emitted for actions affecting the state of the entire canister, such as updates to canister-wide settings or features.
   - **Event Data**: Includes the block details logged to the ICRC-3 Transaction Log, which documents the transaction specifics related to the event.

2. **List-Level Events**:
   - **Event Name**: Formatted as `icrc75:{canister-id}:{list_id}:{btype}`
   - **Description**: Events specific to individual lists, such as changes in list membership, permissions, or other properties.
   - **Event Data**: Similar to canister-level events, these include the transaction details as recorded in the ICRC-3 Transaction Log.


<!--
```candid ICRC-7.did +=
<<<Type definitions>>>

service : {
  <<<Methods>>>
}
```
-->
