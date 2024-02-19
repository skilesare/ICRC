# ICRC-59: Static NFT Metadata Interface Standard

|ICRC|Title|Author|Discussions|Status|Type|Category|Created|
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|59|Static NFT Metadata Interface|Austin Fatheree - @skilesare|TBD|Idea|Standards Track - NFT, Metadata|TBD|


## 1. Overview

ICRC-59 defines the interface for **Non-Fungible Tokens (NFTs)** on the Internet Computer with **static metadata** that does not change after minting. 

### Goals

1. **Define a Standardized Mint Interface:** Provide a clearly defined protocol for the minting of NFTs with static metadata that does not change post-minting. This includes specifying how metadata and associated media are included during the minting process and how they contribute to the uniqueness and identity of the NFT.

2. **Incorporate Static Media Library Management:** Integrate the ICRC-56 System for adding and managing static media associated with NFTs. This system should account for media additions to the blockchain, ensuring these additions are reflected accurately within the NFT’s metadata and its static hash.

3. **Establish Burn Interface and Semantics:** Detail the process and expected outcomes of burning NFTs within the ecosystem, including how the act of burning affects the total supply of NFTs and the state of associated metadata and media.

4. **Standardize NFT Hash Determination:** Describe the method for calculating the hash of an NFT, particularly focusing on how static metadata and media are considered in this calculation. This process will leverage ICRC-56 (Canister File System) to assure consistent and reliable hash generation.

5. **Integrate with ICRC-3 Transaction Logs:** Define a subset of transaction log operations specific to ICRC-59 compliant NFTs, such as operations for data staging, minting, and burning. This integration aims to provide transparency and traceability for actions performed within the ICRC-59 ecosystem.

## 2. Design Principles

ICRC-59 aims to establish a universal, interoperable protocol for managing static NFT metadata within the Internet Computer ecosystem, promoting a standardized approach for developers and users alike.

## 3. Definitions

- **NFT (Non-Fungible Token)**: A digital asset representing ownership or proof of existence of a unique item or asset on a blockchain.
- **Metadata**: Data providing information about the NFT's characteristics, which for ICRC-59, remains unchanged post-minting.
- **Minting**: The process of creating new NFTs.
- **Burning**: The process of permanently destroying NFTs.

## 4. Data Representation

### 4.1 NFT Identification

NFT identification is a crucial component of the Static NFT Metadata Interface (ICRC-59) Standard. It ensures that each NFT within the DFINITY's Internet Computer ecosystem is uniquely identifiable. This section elaborates on the NFT identification mechanisms including the use of token IDs, the process for converting string-based token IDs to numerical values, and the generation of a hash that validates a static NFT.

### Identification by User Selected token_id

In ICRC-59, by default, all token IDs (`token_id`) MUST be represented by natural numbers (`Nat`). This is crucial for ensuring a consistent and standardized method for referring to different NFTs. The `token_id` acts as a unique identifier for each NFT, facilitating their tracking, transfer, and other operations.

### Process for Using and Converting Strings to Nats for Users That Want Strings for Token IDs

Some developers prefer to utilize string-based identifiers for tokens for various reasons such as readability or to follow a specific naming convention. ICRC-59 accommodates this preference by allowing strings to be converted to natural numbers using the function `bytesToNat(textToBytes(token_id_as_string))` as defined below:

```typescript
public func textToByteBuffer(_text : Text) : Buffer.Buffer<Nat8>{
    let result : Buffer.Buffer<Nat8> = Buffer.Buffer<Nat8>((_text.size() * 4) + 4);
    for(thisChar in _text.chars()){
      for(thisByte in nat32ToBytes(Char.toNat32(thisChar)).vals()){
          result.add(thisByte);
      };
    };
    return result;
};

public func textToBytes(_text : Text) : [Nat8]{
    return Buffer.toArray(textToByteBuffer(_text));
};

public func bytesToNat(bytes : [Nat8]) : Nat {
    var n : Nat = 0;
    var i = 0;
    Array.foldRight<Nat8, ()>(bytes, (), func (byte, _) {
      n += Nat8.toNat(byte) * 256 ** i;
      i += 1;
      return;
    });
    return n;
};
```

This conversion process ensures that string-based token identifiers can be seamlessly integrated within the ICRC-59 standard while maintaining the core requirement for numerical token IDs.

### Process for Creating the Hash Used to Validate a Static NFT

The integrity and authenticity of a static NFT are critical, particularly since the metadata does not change post-minting. ICRC-59 specifies a hash generation process to validate an NFT, combining its unique metadata with associated media content:

```
sha256(repIndyHash(metadata)| (repIndyHash(Array[media hashes])))
```

This compound hash includes:

- The representative independent hash of the metadata (`repIndyHash(metadata)`), ensuring that the NFT's descriptive attributes are factored into its identity.
- A hash of the media media associated with the NFT. This ensures that media content is consistent.

This hashing process ensures that both the metadata and media content of the NFT are integral to its validation, providing a robust mechanism for asserting the NFT's authenticity and uniqueness within the Internet Computer ecosystem.

### 4.2 Metadata Structure

The metadata structure for ICRC-59 NFTs is designed to be immutable post-minting, offering a reliable and constant metadata set that represents each NFT throughout its lifecycle.

#### Static Metadata Schema Definition

Each NFT under the ICRC-59 standard consists of a predefined set of metadata fields, some of which are mandatory (MUST), and others optional (MAY), allowing for flexibility while maintaining a standard structure.

#### Mandatory Metadata Fields

Each NFT MUST have the following metadata items defined in the metadata schema:

1. `icrc59:id` (`Nat`): A unique identifier for the NFT, representing the `tokenId`. This is a crucial piece serving as the primary key for NFT identification within the ecosystem.

#### Optional Metadata Fields

In addition to the mandatory fields, the metadata schema MAY include the following items to enhance the NFT's descriptive quality and utility:

1. `icrc59:primary` (`Text`): The primary asset identifier within the library, intended for detailed views or primary representation of the NFT.

2. `icrc59:preview` (`Text`): Library ID pointing to a representation of the NFT optimized for previews, such as thumbnails or summary views within wallets or listings.

3. `icrc59:experience` (`Text`): Library ID pointing to a web application file, that provids an interactive or informative digital experience relevant to the NFT.

4. `icrc59:resource:{system}:{tag}` (`Text`): An asset identifier tailored to specific development environments or use cases, facilitating adaptability across different platforms and interfaces. ie `icrc59:resource:ios:20x20`

5. `icrc59:library`: a structure that defines the library files that are held inside the NFT(See section 4.3)

### 4.3 Media Library and File Storage

In the realm of non-fungible tokens (NFTs), an essential aspect is the management of associated media content and file storage. The ICRC-59 standard leverages the ICRC-56 canister-based file system for the storage of files related to NFTs. This section elaborates on the usage of ICRC-56 for file storage and outlines the `icrc59:library` schema, defining each possible child member to ensure a comprehensive understanding of managing media libraries within ICRC-59 compliant NFTs.

#### ICRC-56 Usage for Storing Files

ICRC-56 serves as a foundational layer for storing files on the Internet Computer (IC) in an organized and accessible manner. For NFTs adhering to the ICRC-59 standard, ICRC-56 facilitates the management of on-chain media files associated with NFTs. The integration ensures that files are not only securely stored but also readily accessible, closely linked with the NFT they pertain to. The file system structure enables the placement of NFT-specific media under a unique path that correlates directly with the NFT ID, thereby ensuring efficient retrieval and management.

Files MUST be staged in the file system before the associated NFT is minted, guaranteeing that all referenced media is available upon the NFT's creation. This staging process is crucial for ensuring that the NFT's integrity and the immutability of its linked media content are maintained and that the ultimate hash of the NFT stays consistent.

#### `icrc59:library` Schema

The icrc59:library node consists of an Array variant where each item in the library is a Map variant in the array.

The `icrc59:library` schema delineates the structure for organizing and referencing media files associated with NFTs. This schema is designed to catalog the various forms of media content pertinent to an NFT, facilitating a structured approach to media management. Below are the key elements within the `icrc59:library` schema, each with specific attributes to optimize the organization and accessibility of media files:

1. **`icrc59:library:id`** (#Text(id)): - Required - Each entry in the media library is assigned a unique ID, which MAY correspond to its path in the ICRC-56 file system. This identifier ensures that every media file can be distinctly referenced and accessed.

2. **`icrc59:library:title`** (#Text(title)): - Optional - A human-readable title for the media file intended for display purposes. This title helps users identify the content of the media at a glance.

3. **`icrc59:library:encoding`** (#Text(encoding)): - Optional, defaults to 'identity' - Specifies the encoding method used for the file, if any. This attribute is optional and should be provided if the file's encoding differs from its natural format, aiding in its correct interpretation and rendering.

4. **`icrc59:library:type`** (#Text(locationType)): - Required - Indicates the type of location where the file resides, such as within the NFT’s specific media library or a collective media library shared across multiple NFTs.

5. **`icrc59:library:location`** (#Text(location)): - Required - Provides a reference to the file's storage location. If utilizing ICRC-56, this would be the root path used within the file system framework. For external storage solutions (e.g., IPFS, Arweave), a complete URL or appropriate locator should be provided.

6. **`icrc59:library:fileHash`** (#Blob(hash)): - Recommended - A cryptographic hash of the file content, ensuring integrity and serving as an immutable fingerprint of the media at the time of the NFT's minting.

7. **`icrc59:library:mimeType`** (#Text(mimeType)): - Recommended - Describes the MIME type of the file, informing systems of the file's format and facilitating appropriate handling and rendering.

8. **`icrc59:library:size`** (#Nat(size)): - Recommended - The size of the file, measured in bytes. This information can be vital for applications that manage data transfer or display estimates of download times.

9. **`icrc59:library:sort`** (#Nat(sortOrder)): - Optional - An optional attribute to specify the display sequence of media files when presenting multiple items. This sorting mechanism allows for the curated arrangement of media in user interfaces.

10. **`icrc59:library:chunks`** (#Map): - Optional - This is particularly relevant for media types such as video or audio that may benefit from a chunked delivery scheme. Each chunk is defined similarly to a full file, inclusive of its unique ID, encoding, type, location, and file hash, mirroring the structure of the library schema to accommodate segmented content delivery.

#### Library Types

The ICRC-59 standard introduces a series of library types designed to cater to different storage needs and scenarios for NFT media files. The following outlines each library type, its specific use case, and an illustrative example:

##### icrc59:location:icrc56global

This library type specifies that the media file is located within another icrc56 compatible library on the Internet Compute. It is primarily used for storing media files that are common across multiple collections, promoting efficient storage by avoiding duplication of identical files. Warning: if the creator does not control these files, or stops funding them, the files may disappear.

Example:

`("icrc59:library:location", "jwcfb-hyaaa-aaaaj-aac4q-cai:icrc56/collection/sample-file.txt")`

##### icrc59:location:icrc56collection

This library type specifies that the media file is located within the collection's media library on the Internet Computer, employing the ICRC-56 standard for file management. It is primarily used for storing media files that are common across multiple NFTs within the same collection, promoting efficient storage by avoiding duplication of identical files.

Example:

`("icrc59:library:location", "/icrc56/collection/sample-file.txt")`

##### icrc59:location:icrc56nft

This type indicates that the media file resides in the NFT's specific media library, also managed by ICRC-56. It suits scenarios where media files are unique to individual NFTs, requiring dedicated storage per NFT.

Example:

`("icrc59:library:location", "/icrc56/-/3948594/sample-file.txt")`

##### icrc59:location:web

Specifies that the media file is hosted on the web, accessible via a fully defined HTTP/HTTPS URL. This type is useful for referencing externally hosted media while ensuring NFT metadata remains lightweight.

Example:

`("icrc59:library:location", "https://mydomain.com/nft/47584/pfp.jpg")`

##### icrc59:location:ipfs

Indicates that the file is stored on the InterPlanetary File System (IPFS), providing decentralized storage solutions. It is beneficial for scenarios emphasizing decentralization and permanence of media files.

Example:

`("icrc59:library:location", "/ipfs/QmTzQ1Nn3fVZErF5uhYf4D3emKRgxYm3LjdhKpK5UH8Dgj")`

##### icrc59:location:btcordinal

This library type denotes that the file is a bitcoin ordinal, integrating unique identifiers from the Bitcoin blockchain into the NFT ecosystem. It represents a crossover utility between Bitcoin and Internet Computer NFTs.

Example:

`("icrc59:library:location", "/ordinal/680000/245/2/1")`

following:

`/ordinal/<block-height>/<tx-index>/<output-index>/<inscription-index>`

##### icrc59:location:arweave

Specifies that the file is stored on Arweave, a service offering permanent, blockchain-based file storage. It aligns with use cases prioritizing long-term accessibility and immutability of media files.

Example:

`("icrc59:library:location", "https://arweave.net/1a2b3c4d5e6f7g8h9i")`

##### icrc59:location:evm

Represents a file inscribed in an Ethereum Virtual Machine (EVM) contract, encapsulating scenarios where NFTs or associated media cross the realms between the Internet Computer and EVM-compatible networks.

Example:

`("icrc59:library:location", "/evm/1/0xContractAddress123/storage/0xb10be7f45a036a2e2ca02aee5eae3ab60dac98130c1e9079a0756b444f21e898
")`

Transaction input:
`/evm/<chain-id>/<contract-address>/<block-number>/<transaction-index>/input/<start-byte>:<end-byte>`

`/evm/1/0xContractAddress123/1200000/15/input/64:128`

Contract Storage:
`/evm/<chain-id>/<contract-address>/storage/<variable-hash>`

`/evm/1/0xContractAddress123/storage/0xb10be7f45a036a2e2ca02aee5eae3ab60dac98130c1e9079a0756b444f21e898`

Emitted log:

`/evm/<chain-id>/<contract-address>/<block-number>/<transaction-index>/logs/<log-index>/<topic-index>`

`/evm/1/0xContractAddress123/1200000/15/logs/0/1`


##### Example

Example structure
```
("icrc59:library", 
  #Array([#Map([
    ("icrc59:library:id", #Text("sample-file")), //unique ID (may be path in filesystem)
    ("icrc59:library:title", #Text("A sample file")), //a title for the file to be displayed by browsers
    ("icrc59:library:encoding", #Text("identity")), //optional if not identity
    ("icrc59:library:type", #Text("icrc59:location:icrc56collection")),
    ("icrc59:library:location", #Text("/icrc56/collection/sample-file.mp4")),//if icrc56 then local root can be used
    ("icrc59:library:fileHash", #Blob([...bytes...])), 
    ("icrc59:library:mimeType", #Text("video/mp4")),
    ("icrc59:library:size", #Nat(24234324234)),
    ("icrc59:library:sort", #Nat(0)), //optional - for display purposes
    ("icrc59:library:chunks", #Map([ //used for video or audio chunking scheme to point to a list of chunks
      ("icrc59:library:id", #Text("sample-file.0")), //unique ID (may be path in filesystem)
      ("icrc59:library:encoding", #Text("identity")),//optional if not identity
      ("icrc59:library:type", #Text("icrc59:location:icrc56collection")),
      ("icrc59:library:location", #Text(/icrc56/collection/sample-file.0.hls)),//if icrc56 then local root can be used
      ("icrc59:library:fileHash", #Blob([..bytes..])),
      ("icrc59:library:size", #Nat(2048000))]))
])]))
```

## 5. Update Methods

Please reference the [Generally-Applicable Specification](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#generally-applicable-specification) section of the ICRC-7 specification as the update methods in ICRC-59 comply with the specification there.

### 5.1 icrc59_stage

#### Data Types

```candid
type StageArg = record {
  token_id : Nat; 
  metadata: Value;
  memo : opt blob;
  created_at_time : opt nat64;
};

type StageResponseError = variant {
  GenericError : record {error_code: Nat; message: Text;};
  Unauthorized;
  TooOld;
  CreatedInFuture : record { ledger_time: nat64 };
  Duplicate : record { duplicate_of : nat };
};

type StageResponse = {
  #Ok: Nat; // Transaction id
  #Err: StageResponseError;
};
```

#### Method Description

`icrc59_stage` is a method to stage metadata for an NFT without completing the minting process. This allows the metadata to be preloaded and verified before minting the NFT. The method takes a `StageArg` argument containing the token ID, metadata, optional memo, and `created_at_time`. The response is a `StageResponse`, indicating success with a transaction ID or detailing any errors occurred during staging.

### 5.2 icrc59_mint

#### Data Types

```candid
type MintArg = record {
  token_id : Nat; 
  owner: Account;
  memo : opt blob;
  created_at_time : opt nat64;
};

type MintResponseError = variant {
  GenericError : record {error_code: Nat; message: Text;};
  Unauthorized;
  TooOld;
  CreatedInFuture : record { ledger_time: nat64 };
  Duplicate : record { duplicate_of : nat };
};

type MintResponse = {
  #Ok: {
    transaction_id: Nat; // Transaction id
    hash: Blob; // NFT hash
  };
  #Err: MintResponseError;
};
```

#### Method Description

`icrc59_mint` mints an NFT with previously staged metadata. This method requires a `MintArg` containing details about the token ID, owner, optional memo, and `created_at_time`. The method response is a `MintResponse`, providing a successful transaction ID and NFT hash or an error detailing why the minting failed.

### 5.3 icrc59_stage_and_mint

#### Data Types

```candid
// Combines StageArg and MintArg
type StageAndMintArg = record { 
  token_id : Nat; 
  metadata: Value;
  owner: Account;
  memo : opt blob;
  created_at_time : opt nat64;
};

// Combines StageResponse and MintResponse
type StageAndMintResponse = {
  #Ok: {
    stage_transaction_id: Nat;
    mint_transaction_id: Nat;
    hash: Blob;
  };
  #Err: variant {StageError: StageResponseError; MintError: MintResponseError;};
};
```

#### Method Description

`icrc59_stage_and_mint` combines the staging and minting process into a single atomic operation for efficiency and convenience. It takes a `StageAndMintArg` and returns a `StageAndMintResponse`, which provides transaction IDs for both staging and minting processes, along with the NFT hash, or an error indicating which step failed.

### 5.4 icrc59_burn

#### Data Types

```candid
type BurnArg = record {
  token_id : Nat;
  memo : opt blob;
  created_at_time : opt nat64;
};

type BurnResponseError = variant {
  GenericError : record {error_code: Nat; message: Text;};
  Unauthorized;
  TokenNotFound;
  TooOld;
  CreatedInFuture : record { ledger_time: nat64 };
  Duplicate : record { duplicate_of : nat };
};

type BurnResponse = {
  #Ok:  Nat; // Transaction id
  #Err: BurnResponseError;
};
```

#### Method Description

`icrc59_burn` provides the interface to permanently remove an NFT from the collection. This method accepts a `BurnArg` containing the token ID, optional memo, and `created_at_time`. It returns a `BurnResponse` indicating success with a transaction ID or an error detailing the reason for burn failure. Post-burning, the NFT is considered non-existent within the collection, though its historical data remains accessible through transaction logs. The owner should be reported as the NNS Management canister "aaaaa-aaa" with a subaccount of sha256("burn").

## 6. Query Interface

### 6.1 Retrieving NFT Metadata

Metadata MAY ve retrieved via the standard ICRC-7 methods of `icrc7_collection_metadata` and `icrc7_token_metadata`.

#### Overview

The retrieval of NFT metadata in ICRC-59 introduces enhancements that cater to the static nature of the NFTs it concerns. These adaptations ensure that both the integrity of an NFT's metadata and its association with the NFT can be validated efficiently.

#### icrc59_tokens Query

##### Purpose

`icrc59_tokens` augments the ICRC-7 `icrc7_tokens` query, providing a comprehensive view of the available NFTs in a collection along with a critical addition—the hash of each NFT. This enhances the query's utility by furnishing a cryptographic summary of each NFT's static content, directly tying the NFT's identity to its metadata's integrity.

##### Return Structure

The query returns a Vector of tuples, with each tuple containing:
- **token_id** - nat: As defined in ICRC-7, representing the unique identifier of the NFT.
- **hash** - blob: A 32 byte Blob representing the cryptographic hash of the NFT's associated static metadata. This hash serves as a fingerprint of the NFT's content, establishing a verifiable link between the NFT and its metadata at the time of minting.

#### icrc59_token_metadata Query

##### Purpose

`icrc59_token_metadata` builds upon `icrc7_token_metadata` by incorporating a hash of the NFT into the response structure. This inclusion addresses the need for verifying the immutability of an NFT's static metadata—a critical feature for collections that promise unchanged content over time.

##### Return Structure

The response is a tuple with the following elements:
- **token_id** - nat: The unique identifier of the queried NFT.
- **MetadataMap** - vec (text, Value): A map of metadata attributes following the ICRC-7 `Value` type definitions, presenting the static metadata properties of the NFT.
- **Hash** - blob : A Blob representing the cryptographic hash of the NFT's static metadata. This hash facilitates the verification of the metadata's authenticity and immutability.

#### Special Considerations for Staged Items

For NFTs that are staged but not yet minted, the query introduces conditional behavior to respect privacy before ownership is established:
- A permission system may be implemented to allow the return of metadata for specific callers during the staging phase. This feature can support use cases where access to pre-minted NFT metadata is necessary under controlled conditions.
- The metadata to non-admin is only returned if the NFT is minted. This behavior aligns with the principle of not exposing metadata for NFTs not officially part of the collection.

### 6.2 Ownership and Existence

Ownership methods and behavior is inherited from ICRC-7.

## 7. ICRC-3 Transaction Log Operations

ICRC-59 leverages the block schema defined in ICRC-3 for recording transaction logs. These logs capture essential actions performed within the ecosystem, such as minting, burning, and staging NFTs, thereby ensuring transparency and traceability. 

### 7.1 Utilizing ICRC-7 Schemas

ICRC-59 adopts the `7mint` and `7burn` block schemas from ICRC-7 for recording minting and burning transactions, respectively. These schemas are employed as follows:

#### Mint Block Schema (`7mint`)

- **Applicability**: Records the minting of an NFT, capturing critical details of the transaction.
- **Fields**:
  - `tx.op` is set to `"7mint"`.
  - `tx.tid` indicates the minted token ID.
  - `tx.to` specifies the account to which the NFT is minted.
  - `tx.meta` contains the NFT's metadata.

#### Burn Block Schema (`7burn`)

- **Applicability**: Logs the burning of an NFT, providing traceability for the reduction in the total supply of NFTs.
- **Fields**:
  - `tx.op` is set to `"7burn"`.
  - `tx.tid` indicates the burned token ID.
  - `tx.from` specifies the account from which the NFT is burned.

These schemas ensure that minting and burning actions within the ICRC-59 ecosystem are consistently documented and aligned with the broader ICRC standards.

### 7.2 Stage Block Schema (`59stage`)

The `59stage` schema is a novel addition introduced by ICRC-59 for capturing the staging of NFT metadata prior to minting. This operation is crucial for preloading and verifying NFT metadata, allowing for a preliminary review and adjustment phase before the NFT becomes officially minted. The schema details are as follows:

#### Stage Block Schema (`59stage`)

- **Applicability**: Records the staging of metadata for an NFT, setting the groundwork for subsequent minting.
- **Fields**:
  1. `tx.op` MUST be `"59stage"` to denote a staging operation.
  2. `tx.tid` MUST contain the token ID for which metadata is being staged.
  3. `tx.from` MAY contain the account staging the metadata. This field is optional and may be used to track the originator of the staged metadata.
  4. `tx.hash` MUST contain a hash of the staged metadata. This hash serves as a verifiable fingerprint of the metadata at the staging phase, ensuring integrity from staging to minting.

The introduction of the `59stage` schema addresses the need for a transparent and traceable process for preparing NFT metadata within the ICRC-59 framework. It represents a preparatory step, allowing stakeholders to validate and adjust metadata as necessary before committing to minting the NFT.

### 7.3 Utilizing ICRC-56 Schemas

ICRC-59 adopts the various block schemas from ICRC-56 for recording the process of uploading files into the file system.

## 8. Http Access

#### 8.1 Overview

The "Http Access" section of the ICRC-59 ("Static NFT Metadata Interface") standard specifies the protocol for accessing NFT metadata and associated media files over HTTP, ensuring that the data associated with NFTs on the Internet Computer can be retrieved using standard web protocols. This approach provides a bridge between the on-chain world of NFTs and the broader internet, allowing for the integration of NFT content into web applications, marketplaces, and other digital platforms.

#### 8.2 Accessing NFT Metadata

NFT metadata MUST be accessible via an HTTP GET request following the ICRC-23 schema. The request and response formats are as follows:

##### Request Format:

```
https://{canisterid}.icp0.io/---/icrc59/-/{nftid}/metadata?mode={mode}
```

Where:
- `{canisterid}`: The unique identifier of the canister hosting the NFT.
- `{nftid}`: The unique identifier of the NFT.
- `{mode}`: The format in which the metadata should be returned. Valid values are `candid` and `json`.

##### Response Format:

- When `?mode=candid` is specified, the response MUST be the Candid representation of the NFT's metadata.
- When `?mode=json` is specified, the response MUST be the JSON representation of the NFT's metadata, as defined by the translation rules in ICRC-16.

#### 8.3 Accessing Associated Media Files

Media files associated with NFTs MUST be accessible via HTTP GET requests. The ICRC-59 standard defines two schemes for accessing these files to accommodate different storage strategies.

##### Direct Access Scheme:

```
https://{canisterid}.icp0.io/---/icrc56/media/{nftid}/{path}
```

Where:
- `{path}`: The path to the media file within the NFT's media library.

This scheme SHOULD be used for accessing files directly associated with an NFT, leveraging the ICRC-56 file storage standard.

##### Alternative Access Scheme:

```
https://{canisterid}.icp0.io/---/icrc56/media/{nftid-as-string}/{path}
```

This scheme MAY be used as an alternative, treating the NFT ID as a string. It provides flexibility in referencing NFTs, especially when non-numeric identifiers are employed.

##### File Certification:

All media files accessed via these schemes SHOULD be certified using the Internet Computer v2 certification scheme to ensure their authenticity and integrity.

## 9. Transaction Deduplication, Compatibility, and Security

Please refer to the ICRC-7 specification for details on Deduplication, Compatibility, and Security.
