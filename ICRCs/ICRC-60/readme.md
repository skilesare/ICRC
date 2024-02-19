# ICRC-60: Dynamic NFT Metadata Interface Standard

|ICRC|Title|Author|Discussions|Status|Type|Category|Created|
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|60|Dynamic NFT Metadata Interface|Austin Fatheree - @skilesare|TBD|Idea|Standards Track - NFT, Metadata|TBD|

ICRC-60 extends the ICRC-59 standard to define the interface for Non-Fungible Tokens (NFTs) on the Internet Computer with dynamic metadata that can change post-minting. This standard outlines the protocols for minting, burning, updating, and querying dynamic NFTs and their metadata, ensuring compatibility with ICRC-59, ICRC-3, ICRC-56, and other related protocols.

This standard caters to NFTs whose metadata and possibly associated file content may need to be altered or updated after minting, providing a structured approach for these interactions.

## 1. Overview

### 1.1 Goals

The primary goal of the ICRC-60 ("Dynamic NFT Metadata Interface") standard is to extend the foundational principles established in ICRC-59 to facilitate the creation, management, and interaction with Non-Fungible Tokens (NFTs) that feature dynamic metadata capabilities on the Internet Computer ecosystem. These NFTs, unlike their static counterparts, are designed to allow for the modification of their metadata properties post-minting. The specific objectives of ICRC-60 include:

1. **Enable Dynamic Metadata Amendments**: To provide a standardized framework that supports the modification of NFT metadata after the initial minting process. This includes both the refinement of existing metadata fields and the addition of new information as the NFT evolves.

2. **Ensure Metadata Authenticity and Integrity**: Despite the mutable nature of dynamic NFTs, it is imperative to uphold the authenticity and integrity of the metadata. ICRC-60 aims to establish mechanisms that ensure any changes to the metadata are traceable, authorized, and securely recorded, thereby maintaining trust in the NFT's provenance and history.

3. **Define Authorized Update Protocols**: Building upon the security and operational compliance needs, the standard seeks to delineate clear protocols for who can initiate metadata changes, under what conditions, and through what methods. This includes the specification of roles, authorization schemas, and operational protocols that govern metadata updates.

4. **Incorporate Dynamic Activities into ICRC-3 Logs**: To guarantee transparency and auditability, ICRC-60 aims to integrate the recording of dynamic metadata activities within the ICRC-3 transaction log framework. This includes logging operations related to metadata amendments, ensuring that the history of modifications is accessible and unequivocally linked to the NFT.

5. **Standardize Dynamic NFT Interactions**: To foster interoperability and ease of integration across various applications and platforms within the Internet Computer ecosystem, by providing a uniform approach to interacting with dynamic NFTs. This also involves defining how dynamic metadata impacts NFT presentation, exchange, and utility in decentralised applications (dApps).

6. **Safeguard NFT Ecosystem Integrity**: Through the careful design of dynamic metadata standards, ICRC-60 aims to preserve the overall integrity and value of the NFT ecosystem on the Internet Computer. This involves ensuring that the ability to update metadata does not compromise the NFTs' uniqueness, ownership rights, or value proposition.

In achieving these goals, ICRC-60 is poised to unlock new use cases for NFTs, enabling them to adapt over time while providing a secure, transparent, and standardized approach to managing dynamic content.

## 2. Design Considerations

ICRC-60 aims to provide flexibility in NFT metadata management while ensuring the security and integrity of the NFTs within the Internet Computer ecosystem.

## 3. Modifications to ICRC-59

### 3.1 ICRC-16 based metadata

#### Definition

The **ICRC-16 Metadata Standard** is an integral part of the ICRC-60 standard, designed to cater to the dynamic nature of NFTs in the ecosystem. It serves as an extension to the existing Value type used for metadata in ICRC-7 and ICRC-59, incorporating additional types and structures to support dynamic metadata(Namely the Class Variant).

#### Purpose

The primary purpose of this extension is to accommodate NFTs that require metadata to be mutable or immutable after the minting process. This requirement arises in various scenarios where the asset or information represented by the NFT evolves or needs updating over time. For example, imagine a web3 game that uses NFTs as inventory and wants to maintain statistics inside the NFT that travel with it. The extension ensures that such modifications are managed systematically, maintaining the integrity and traceability of changes.

#### Data Structure

The **ICRC-16 Metadata Standard** introduces modifications to the `StageArg` data structure, adding data types specifically designed for handling dynamic metadata. This structure is defined in ICRC-16 and is a supertype of the Value type defined in ICRC-7. Below is the enhanced `StageArg` structure:

```candid

type ICRC16 = variant {
    Int :  int;
    Int8: int8;
    Int16: int16;
    Int32: int32;
    Int64: int64;
    Ints: vec int;
    Nat : nat;
    Nat8 : nat8;
    Nat16 : nat16;
    Nat32 : nat32;
    Nat64 : nat64;
    Float : float;
    Text : text;
    Bool : bool;
    Blob : blob;
    Class : vec (record {name : text; value: ICRC16; immutable: bool});
    #Principal : principal;
    #Floats : vec float;
    #Nats: vec nat;
    #Array : vec ICRC16;
    #Option : opt ICRC16;
    #Bytes : vec nat8;
    #ValueMap : vec (record (ICRC16, ICRC16))>;
    #Map : vec (record {Text; ICRC16});
    #Set : vec ICRC16;
};

type DynamicStageArg = record {
  token_id : Nat; 
  metadata: ICRC16; // Updated to use the ICRC16 type structure for dynamic metadata
  memo : opt blob;
  created_at_time : opt nat64; // Optional specification of the time of creation
};
```

## 4. Data Representation

# 4.1 Metadata Structure for Dynamic NFTs

The metadata structure for dynamic NFTs under ICRC-60 is designed to extend the foundational concepts established by ICRC-59 with enhancements that enable metadata mutability. This adaptability in the metadata allows for a wide range of applications, such as NFTs with attributes that evolve over time or those that incorporate user-generated content post-minting.

### Basic Structure

At its core, the metadata structure of a dynamic NFT retains compatibility with ICRC-59, ensuring that fundamental metadata attributes such as `name`, `description`, and media references are present. These attributes serve as the static base upon which dynamic features are built.

### Mutability with "icrc60:apps"

A distinctive feature of ICRC-60 is the "icrc60:apps" node within the metadata. This node is a sophisticated addition that brings dynamic capabilities to NFT metadata. It outlines the permissions and structure for apps to interact with and update specific parts of the NFT's metadata.

Structure:
- Each application or dApp wanting to interact with the NFT must be declared within the "icrc60:apps" node.
- The specific permissions for reading, writing, and altering permissions are established per app, using the `DappPermissions` types (e.g., `#Text("icrc60:public")`, `#Text("icrc60:nft_owner")`, etc.).

### Example of "icrc60:apps" Node in Metadata

```candid
("icrc60:apps", #Map([
  ("uniqueAppName", #Class([
    {name = "icrc60:apps:read"; value=#Text("icrc60:public"); immutable=true},
    {name = "icrc60:apps:write"; value=#Text("icrc60:nft_owner"); immutable=false},
    {name = "icrc60:apps:permissions"; value=#Text("icrc60:system"); immutable=true},
    {name = "icrc60:apps:data"; value=#Class([...]); immutable=false},
  ]))
]))
```

This structure allows for granular control over who can see and modify certain parts of the NFT's metadata, ensuring that updates are controlled and security is maintained.

## 4.2 Data Node Permissions

To facilitate the secure and controlled updating of dynamic NFT metadata, ICRC-60 introduces a comprehensive permission model that governs interactions with each data node within an NFT's metadata structure, particularly within the "icrc60:apps" node.

### Permission Structures

1. **Public ("icrc60:public"):** Any user can read the metadata. Public is not allowed on write or permission nodes.
   
2. **Owner Exclusive ("icrc60:nft_owner", "icrc60:collection_owner", "icrc60:collection_any_nft_owner"):** Only the NFT owner, collection owner, or owner of another NFT in the collection can update the metadata, with read permissions potentially being more open.

3. **System-Level ("icrc60:system"):** Updates can only be made through the canister's internal logic, ensuring that changes are driven by on-chain activities or smart contract functions.

4. **Group Permissions (variant Array( variant Text: icrc60:groupPermission; variant Principal({GroupCanister}); variant Text{groupName})):** A named group of users or entities with defined permissions, allowing for collaborative interaction with the NFT based on group membership. A future ICRC will define the group permissions system and it is expected that a canister implementing the group permission system will use that standard.

5. **Specific Permissions (variant Array( variant Text: icrc60:list; variant Array(Principals))):** A named group of principals with defined permissions, allowing for collaborative interaction with the NFT based on a users principal membership. 

6. **No Permissions ("icrc60:none"):** Explicitly indicate that no one has the rights to change permissions. 

### Updating Permissions

The "icrc60:apps:permissions" attribute within each app's Class structure is crucial for defining who can modify permissions for the app. This ensures a secure environment where permission changes are carefully controlled to prevent unauthorized access or alterations.

### Immutable Flags

Each permission and data node can be marked as `immutable`, determining if its structure or permissions can be revised post-creation. This flag provides stability for certain critical metadata aspects, ensuring they remain unchanged throughout the NFT's lifecycle.

### Example Use Case Scenario

Consider a gaming NFT where an app updates the NFT based on player achievements:
- The app has write permission limited to the ("icrc60:list", #Array([#Principal({gameserverprincipal})])), ensuring that only the games's gameplay affects the specific NFT Node.
- The "icrc60:apps:data" node could contain dynamic data such as "playerScores" and "achievementUnlocked", facilitating real-time updates based on in-game events.

This dynamic structure and permission model equips ICRC-60 NFTs with the flexibility and security necessary for a broad spectrum of use cases beyond static collectibles, fostering innovation within the NFT space on the Internet Computer.

## 4.3 The System Node

The concept of the "System Node" within the ICRC-60 standard plays a pivotal role in the management of canister and implementation defined NFT metadata. The system node is just like any other app data node, but has a defined namespace and permission set

#### Configuration Example

```motoko
("icrc60:system", #Class([
    {name = "icrc60:apps:read"; value=#Text("icrc60:public"); immutable=true},
    {name = "icrc60:apps:write"; value=#Text("icrc60:system"); immutable=true}, 
    {name = "icrc60:apps:permissions"; value=#Text("icrc60:system"); immutable=true},
    {name="icrc60:system:icrc7:owner", value=#Array[(#Principal("aaaaa-aaa"), #Option(#Blob("...")))]; immutable=false;},
    { name="icrc60:system:icrc7:owner", value=#Array[(#Principal("aaaaa-aaa"), #Option(#Blob("1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c1d1a1b1c1d")))]; immutable=false;},
    {name="icrc60:system:icrc98:soulBound", value=#Text("false"), immutable=false;},
    {name="icrc60:system:icrc59:minted", value=#Text("true"), immutable=false;},
    {name="icrc60:system:icrc202:network", value=#Principal("aaaaa-aaa"), immutable=true;},
    {name="icrc60:system:icrc202:node", value=#Principal("aaaaa-aaa"), immutable=true;},
    {name="icrc60:system:icrc202:authenticator", value=#Principal("aaaaa-aaa"), immutable=true;},
    {name="icrc60:system:icrc202:physical", value=#Text("true"), immutable=true;},
    {name="icrc60:system:icrc202:escrowed", value=#Text("false"), immutable=false;},
    {name="icrc60:system:icrc8:saleId", value=#Nat(234543), immutable=false;}, //ICRC8 sale id
    {name="icrc60:system:icrc202:royalties", value=#Map([
      ("com.origyn.royalties.primary", #Map([
        ("com.origyn.royalties.node", #Map([
          ("com.origyn.royalties.fixed", #Nat(100000000)),
          ("com.origyn.royalties.tokenCanisterID", #Principal("jwckb-dkdkdk-dkkdkd-kdkdk")),
          ("com.origyn.royalties.tokenDecimals", #Nat(8)),
          ("com.origyn.royalties.tokenFee", #Nat(200000)),
        ])),
        ("com.origyn.royalties.network", #Map([
          ("com.origyn.royalties.fixed", #Nat(100000000)),
          ("com.origyn.royalties.tokenCanisterID", #Principal("jwckb-dkdkdk-dkkdkd-kdkdk")),
          ("com.origyn.royalties.tokenDecimals", #Nat(8)),
          ("com.origyn.royalties.tokenFee", #Nat(200000)),
        ])),
        ("com.origyn.royalties.originator", #Map([
          ("com.origyn.royalties.percent", #Float(0.01))
        ])),
      ]))
    ]), immutable=false;},
]))
```

The only other data that may change should be in the icrc60:system node which may report and store system based data that may be important to the the NFT ecosystem. The System node SHOULD honor the immutable tag on member nodes, but users MUST assume that even immutable values can be changed by controlling DAOs.

The system node should not be included in staged metadata and should be generated by the system upon staging.

## 4.4 Collection Metadata

Collection metadata in the ICRC-60 ("Dynamic NFT Metadata Interface") standard refers to the overarching data that describes the entire collection of NFTs within a specific ecosystem or platform on the Internet Computer. Unlike individual NFT metadata that pertains to singular tokens, collection metadata encompasses attributes and details relevant to the collection as a whole. The ICRC-60 standard integrates the concept of the app node system, extending its application to not just individual NFTs but also at the collection level.

## 4.5 Files and Media

### 4.5.1 Differences between ICRC-59 and ICRC-60 in Files and Media Handling

ICRC-60 expands upon the ICRC-59 standard by introducing mechanisms that allow for dynamic updates to NFT media. The key difference in files and media handling between ICRC-59 and ICRC-60 lies in the capability of ICRC-60 to recalculate and update the NFT hash each time there is a change in files, thereby enabling the dynamic nature of metadata and media content associated with NFTs.

#### Recalculation of NFT Hash

Every time there is a change to the files or media associated with an ICRC-60 NFT, the NFT hash needs to be recalculated to reflect these changes. This approach ensures the integrity of the NFT by linking the current state of its files and media directly to its identifiable hash. The recalculation process takes into consideration all facets of the NFT's metadata, including newly added or updated media files.

### 4.5.2 Setting Permissions for Files and Media in NFTs

#### Permission Settings

The same set of permissions apply to nodes as apply to library entries.

#### Write Permissions

The ICRC-60 standard allows for defining permissions for who can update (write to) the files and media associated with an NFT. The default permission for executing write operations is set to the collection owner, but this can be optionally changed by specifying `("icrc60:library:write", WritePermission)` in the metadata for the applicable library asset. The WritePermissions include capabilities such as replacing media or deleting media resources from the NFT's library.

#### Public Read and Controlled Access

By default, files and media are accessible to the public for reading, as per `("icrc60:library:read", ReadPermission)`, which defaults to a public access setting. This ensures that NFT assets are widely accessible, enhancing the visibility and utility of the NFT. However, access control can be tightened, and if a caller does not possess the specified read permission, the asset in question will not appear in the NFT Metadata library section visible to that caller.

This controlled access mechanism supports use cases where privacy or restricted access to certain NFT-associated files and media is desired.

Note: This is only pseudo-privacy. It is likely that a media file may be recoverable by a non-permissioned user by looking at the transaction logs and/or ingress logs.  For true privacy the library will need to implement a future ICRC around VetKeys.

### 4.5.3 Example of Library Node

```
("icrc59:library", 
  #Array([#Map([
    ("icrc59:library:id", #Text("sample-file")), //unique ID (may be path in filesystem)
    ("icrc60:library:write", #Text("icrc60:collection_owner")),
    ("icrc60:library:read", #Text("icrc60:public")),
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

### 4.6 - Adding Library Items to an NFT

Write permissions for new media library items is defined in the "icrc59:library:manage" data item at the top of collection metadata.  This item should be copied into the system node upon minting and applied to the NFT.  It should only be changeable via governance if the NFT collection accounts for that possibility.

## 5. Dynamic Update Interface

### 5.1 Updating Metadata

#### Function Definition and Data Types

The ICRC-60 standard introduces a dynamic update interface, allowing authorized operators to modify the metadata of an NFT post-minting. This functionality is crucial for use cases where NFT metadata needs to evolve or be updated over time.

##### Function Signature:

```candid
type Transform = record {
  name: Text,
  mode: TransformMode
};

type TransformMode = variant {
  Set: ICRC16,
  Lock: ICRC16,
  Next: vec Transform
};

type TransformError = variant {
  Unauthorized,
  NotFound,
  InvalidRequest,
  Immutable: opt text,
  GenericError: record {
    error_code: nat,
    message: text
  },
  TooOld,
  CreatedInFuture: record {
    ledger_time: nat64
  },
  Duplicate: record {
    duplicate_of: nat
  }
};

type UpdateRequest = {
  token_id: opt nat, //a null token_id applies to collection metadata
  app: text,
  transform: Transform,
  created_at: opt Nat64,
  memo: opt Blob
};

icrc60_update_metadata : (request: vec UpdateRequest) -> async vec (variant {#Ok:Nat, #Err: TransformError});
```

#### Details:

- `token_id` (Option<Nat>): An optional field specifying the token ID for which metadata is being updated. A null value indicates that the collection's metadata itself is being manipulated.
- `app` (Text): Identifier of the app or module requesting the metadata update. This field specifies under which namespace within `icrc60:app` the data will be manipulated.
- `transform` (Transform): A structure defining the transformation to be applied to the metadata. It includes the `name` of the metadata field to be updated and the `mode` determining how the update should be performed.
- `created_at` (Option<Nat64>): An optional timestamp indicating when the update request was created. This helps in managing request validity and ordering.
- `memo` (Option<Blob>): An optional field to include additional data or a note with the update request. This could be used for logging, tracing, or application-specific purposes.

#### TransformMode:

- `Set` (ICRC16): Directly sets the specified metadata field to a new value.
- `Lock` (ICRC16): Sets and then locks the specified metadata field immutable, preventing further changes.
- `Next` (vec Transform ): Allows for a sequence of transformations to be applied, facilitating complex updates.

#### Authorization:

The update operation checks that the caller has the required permissions to modify metadata. The required permission level is specified within the `icrc60:apps` node of the metadata. Depending on the operation and targeted metadata section, different levels of authorization can be required, ranging from the NFT owner to specific app permissions.

#### Response:

The function returns a vector of results, each corresponding to the update request for a specific NFT or metadata field. Success is indicated by `#Ok` containing the transaction index of the update. Errors are returned as `#Err` variants, providing detailed information about the nature of the failure.

# 6. Query Interface for ICRC-60

The Query Interface for ICRC-60 updates the ICRC-59  mechanism for retrieving NFT metadata, updating the type to support ICRC-16 data.

## 6.1 - icrc60_token_metadata_query

#### Function Signature

```candid
icrc60_token_metadata_query :  (token_ids: vec nat) -> async (Nat, vec record{text; ICRC16}, Blob) query;
```

#### Input

- **`token_id` (Nat):** The unique identifier of the NFT whose metadata is being queried.


#### Output

- **Tuple (Nat, Map<Text, ICRC16>, Blob):** A tuple containing the token ID, a map of the current NFT metadata represented using the ICRC16 data type, and a hash of the NFT. The map keys are textual names of the metadata attributes, and their values are ICRC16 variants representing the attribute values. The included hash provides a cryptographic verification of the metadata's integrity at the time of the query. Note: if the item contains read restricted items hidden from the caller, the hash will not match.

# 7. ICRC-3 Transaction Log Operations for Dynamic NFTs

Dynamic NFTs (Non-Fungible Tokens) introduce the ability for the metadata associated with a token to change post-minting. This evolution necessitates the recording of such changes in a systematic and traceable manner, to ensure transparency and audibility within the ecosystem. In light of this, an extension to the ICRC-3 transaction log operations is required, specifically tailored to accommodate the dynamics of NFT metadata updates. This section outlines the "60update" transaction type, its data structure, and the mechanisms for handling data availability and transform access within the ICRC-56 file system.

## 7.1 The "60update" Transaction Type

### Overview

"60update" represents the transaction type dedicated to recording updates made to the dynamic NFT metadata. This transaction type is pivotal in tracking the changes that accrue over the lifetime of an NFT, ensuring that each alteration is logged and traceable back to its origin.

### Data Structure

The "60update" transaction encompasses several fields, detailed as follows:

1. **Transaction Operation (`tx.op`)**: Must be `"60update"` to denote a dynamic metadata update operation.

2. **Token Identifier (`tx.tid`)**: An optional field that indicates the specific NFT subject to the update. If null, the operation applies to collection-level metadata updates, rather than individual NFTs.

3. **Account From (`tx.from`)**: An optional field identifying the account initiating the update. This information provides context on who made the change, offering insights into the update's provenance.

4. **Transform (`tx.transform`)**: A mandatory field that encapsulates the dynamic metadata update's nature. It can either contain a `Transform` data structure detailing the metadata transformation or a Blob hash of such a structure for larger updates.

5. **Resulting Hash (`tx.hash`)**: The resultant hash of the operation’s impact on the NFT, providing a cryptographic snapshot of the NFT's state post-update.

### Handling Data Availability

Given the potential size and complexity of metadata updates, "60update" transactions adopt a flexible approach towards storing the transform data:

- **Small Transforms**: For succinct metadata updates, the full `Transform` structure can be directly embedded within the `tx.transform` field.

- **Large Transforms**: In cases where the metadata update is too voluminous to fit within a single transaction record, a two-step approach is advised:
  - The `tx.transform` field includes a hash of the actual metadata transform.
  - The complete `Transform` structure is concurrently recorded within the ICRC-56 file system, following the path format: `/icrc60/hash/{byte0-3}/{byte4-7}/.../{byte28-31}/data.did`.

This dual-path approach ensures that the critical information is always accessible while catering to the varying sizes of metadata updates. It balances direct access for smaller updates with a robust, decentralized storage solution for more extensive changes.

### Transform Access in ICRC-56 File System

For "60update" transactions leveraging the ICRC-56 file system to store extensive metadata updates, a standardized method for accessing these transforms is necessary. The designated path format facilitates straightforward retrieval:

- Upon receiving a "60update" transaction, if the `tx.transform` field contains a hash rather than a direct `Transform` structure, systems can query the ICRC-56 file system using the specified path.
- This procedure allows systems to fetch the detailed metadata transformation, ensuring that the full context and specifics of the update are available for inspection, auditing, or application logic.

## 8. Http Access for ICRC-60

ICRC-60 follows the same pattern as ICRC-59 except for the following caveats:

Files should be certified via the Internet Computer v2 certification scheme. Note: Due to the dynamic nature of metadata, the canister creator may need to follow a http_request -> http_request_update -> 200 redirect to self -> http_request pattern to certify the asset if there are any non-public read nodes in the metadata. If there are no non-public reads then metadata endpoints SHOULD be re-certified after each update.

Since http_request can only come from the anonymous principal, the canister should expose a way for a user to validate themselves.  It is recommended that an ICRC be developed to allow for the provision of a secure signature schema. (ie. advancing nonce).

## 9. Transaction Deduplication, Compatibility, and Security

Please refer to the ICRC-7 specification for details on Deduplication, Compatibility, and Security.
