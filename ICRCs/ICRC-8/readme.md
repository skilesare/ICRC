|ICRC|Title|Author|Discussions|Status|Type|Category|Created|
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|8|Ledger Native Markets|Austin Fatheree (@skilesare)|https://github.com/dfinity/ICRC/issues/8|Draft|Standards Track||2024-02-01|



# ICRC-8: Ledger Markets

ICRC-8 is the standard for creating an in-ledger marketplace for the trading of NFTs and fungible tokens on the Internet Computer. The standard describes how marketplaces can be implemented directly within token ledger canisters, thus enabling a seamless and trustless environment for buying, selling, and exchanging digital assets. It outlines a series of interfaces and transaction schemas compatible with various ICRC token standards including ICRC-1, ICRC-2, ICRC-4, ICRC-7, and ICRC-37.

ICRC-8 standardizes the functionality needed to place assets into escrow, manage auction mechanics, enforce compliance checks, provide instant trade settlement, and handle multi-token transactions. This is achieved through the definition of modular features such as 'Ask' for sellers, 'Bid' for buyers, 'Escrow' for managing in-progress transactions, and 'Settlement' for finalizing trades. Additionally, ICRC-8 supports advanced transaction mechanics like Dutch and AMM-based auctions, multi-ledger settlement, and handling of unsolicited offers.

This standard enables the emergence of a decentralized finance ecosystem by facilitating the creation of on-chain marketplaces that can securely and efficiently handle high volumes of trading activity across different types of tokens. By providing these standard interfaces and schemas, the ICRC-8 standard aims to foster interoperability, enhance user experience, and ensure consistent behavior across the ledger markets built on the Internet Computer.

## Summary of Key Features

- **Escrow Functionality**: Tokens or NFTs can be placed into escrow within the ledger canister for a trustless transaction environment.
- **Bid and Ask Interfaces**: Standardized ways to create bids for buyers and asks for sellers, with support for auction and fixed-price listings.
- **Transaction Types**: Support for direct sales, auctions including Dutch and AMM-based formats, and engine matching for multi-item trading.
- **Multi-Ledger Settlement**: Enables cross-canister transactions where a single trade can involve assets from multiple token ledgers.
- **Flexibility in Payments**: Support for various ICRC tokens as payment methods within the same marketplace.
- **Commission and Fee Mechanisms**: Configurable fee structures for marketplace operators, brokers, and other participants.
- **Unsolicited Offers**: A mechanism for buyers to make offers to token or NFT owners outside of the context of an existing ask.
- **Encumbrance API**: Supports multi-step, multi-ledger transaction settlement, enabling complex DeFi applications and external matching engines.
- **Security Mechanisms**: Built-in protections against Denial of Service (DoS) attacks and support for token-level and collection-level approvals as extensions of ICRC standards.

## Important Concepts

### Bids are temporal, Asks Persist

In the context of ICRC-8 marketplaces, the distinction between bids and asks is foundational in understanding market dynamics and behaviors. Bids are temporal by nature, representing a buyer's intent to purchase at a specific moment in time. Conversely, asks persist until they are either fulfilled or canceled by the seller.

#### Bids

A bid is made by a prospective buyer who is willing to purchase at a defined price at that particular point in time. A bid is a statement of purchase intent that is valid only for the duration of the call to the canister service. The bid will be executed or placed in escrow(in the case of auctions) by the end of the update call. 

Satisfying bids will have their indeicated assets moved into escrow.  If the transaction does not proceed or the bid expires, escrowed assets must be returned to the bidder.

#### Asks

In contrast, an ask is a standing offer to sell, extended by the seller, which persists on the marketplace until a suitable bid is received or the seller decides to withdraw or alter the ask. An ask reflects the seller's willingness to transact on the terms stated and remains effective until explicitly canceled or settled.

Asks define the terms of sale, including the price, conditions, and in some cases, specific buyer qualifications. Once established, an ask provides a continual opportunity for buyers to engage and match the offer's criteria.

#### Escrow Interaction

Escrow mechanisms in ICRC-8 marketplaces play a vital role in managing bids and asks. As bids and asks come into agreement, the corresponding assets of both parties are placed into escrow. Escrow secures these assets and ensures that neither party can unilaterally alter the agreed-upon terms before the transaction is finalized.

#### Bid Matching and Ask Fulfillment

The ICRC-8 standard facilitates various pathways for bid matching and ask fulfillment:

- **Direct Matching**: Buyers can place bids that directly match an existing ask. Escrowed assets and funds are swapped if conditions are met.
- **Buy-Now Features**: Sellers may set `buy_now` terms on their asks, which can be fulfilled immediately upon receipt of a matching bid.
- **Sweeping the Floor**: Buyers may issue bids designed to match multiple asks simultaneously, effectively 'sweeping the floor' of available assets at a certain price level.
- **Engine Matching**: Advanced matching engine capabilities enable coordination of multiple bids and asks across potentially different canisters for optimized settlements.

### Multi-canister matching and settlement

When deploying an on-ledger marketplace for NFTs and fungible tokens, ensuring efficient transactions across multiple ledgers is crucial. ICRC-8 introduces an innovative system to handle such complexity via an encumbrance mechanism that streamlines multi-canister matching and settlement. This system guarantees that assets earmarked for a transaction remain reserved until all parties fulfill their obligations, enabling secure and reliable multi-ledger trade execution on the Internet Computer.

#### Concept of Encumbrance

Encumbrance within ICRC-8 is an advanced feature that temporarily locks assets or funds for a designated period or until certain conditions are met. It is a form of reservation that prohibits the use of the encumbered items in other transactions. This is especially useful in multi-canister trades where the final settlement occurs in a coordinated manner involving several different canisters.

#### Multi-canister Trade Flow

A typical multi-canister trade involves the following steps:

1. **Engine Match**: A market observer identifies a coincident of wants and files an engine match with one of the canisters holding an ask. The initial ledger, designated as the "leader," confirms the validity of the asks involved in the trade. (icrc8_bid([#engine_match(Details)]))

2. **Leader Encumbrance**: The leader acknowledges the match and encumbers the corresponding asks to itself, ensuring reserved availability for the trade completion.

3. **Notification to Involved Canisters**: The leader sends details about the matched trade to other involved canisters, which, in turn, verify the match and encumber their respective asks to the leader.(relays with calls via icrc8_bid(#engine_match)).

4. **Asset Transfer Coordination**: Upon confirmation of encumbrances, the satellite canisters facilitates the transfer of assets from each canister to a dedicated settlement area. (may need to retrieve escrow info). Each canister asks the ask to be unencumbered.

5. **Completion of the Trade**: Once all encumbrances are honored and assets moved to the settlement area, the buyer's bid fulfills the asks involved, and the trade is executed atomically and settlement distributed.

#### Advantages of the Encumbrance System

- **Security**: By locking the assets until all terms are satisfied, the risk of fraudulent activity or double-spending is significantly reduced.
- **Atomicity**: Trades are executed in a manner that ensures the entire transaction either completes successfully or does not occur at all, preserving consistency across ledgers.
- **Coordination**: The leader orchestrates the entire process, providing a single point of reference for complex multi-canister trades.
- **Efficiency**: Encumbrance optimizes the settlement process by handling the reservation and movement of assets through a centralized leader, reducing the number of cross-canister calls necessary for settlement.

#### Encumbrance Mechanism Implementation

The implementation of an encumbrance system within ICRC-8 consists of specialized data types and methodologies:

- `EncumbranceSpec`: Details the tokens or assets to be encumbered, the trustees responsible, and the timeout for the encumbrance.
- `EncumbranceDetail`: Stores information about the actual encumbrance, including expiration details.

By providing a transparent means to match and settle complex transactions, the encumbrance system strengthens the capability of the Internet Computer to support a robust and thriving DeFi marketplace landscape.
ross different ledgers.

## Non-ledger implementations

While the ICRC-8 standard is primarily designed for ledger-based marketplaces built directly into token canisters, there is a provision for non-ledger implementations. These implementations allow marketplaces to exist outside of the ledger canisters while still adhering to the standard's framework. This enables greater flexibility and empowers developers to build markets with cooperations of ledgers.

Fees may be higher for settlements or operations that occur in non-ledger implementations due to additional overheads in fees being charged on both sides of a transaction. 

## Data Representation

This section specifies the core principles of data representation used in the ICRC-8 standard.

### Account Representation

An `Account` represents the owner of fungible tokens or NFTs:

```candid
type Account = record {
  owner: principal;
  sub_account: opt blob;
};
```

The `sub_account` is an optional field that allows for multiple accounts to exist for a single principal, each identified by a unique subaccount blob.

### Token Specification (TokenSpec)

The `TokenSpec` data type is crucial for identifying tokens in the marketplace, particularly for defining which tokens are involved in a transaction. This type encapsulates the properties of a token, as defined by its residing canister, the token symbol, and the standards that the token follows.

```candid
type TokenSpec = record {
  canister: principal; // The principal ID of the token's canister
  symbol: Text;        // The symbol representing the token
  standards: [ICRCStandards]; // A list of standards the token adheres to
};
```

### ICRC Standards (ICRCStandards)

`ICRCStandards` is a variant that details the support for different token standards by the `TokenSpec`. Each option represents a specific ICRC token standard and potentially carries additional details relevant to that standard.

```candid
type ICRCStandards = variant {
  ICRC1: opt ICRC1TokenSpecDetail;
  ICRC2: opt ICRC2TokenSpecDetail;
  ICRC4: opt ICRC4TokenSpecDetail;
  ICRC7: opt ICRC7TokenSpecDetail;
  ICRC37: opt ICRC37TokenSpecDetail;
  // Additional standards can be added in future ICRCs
  // Group1: ICRC1,ICRC2, ICRC4
  // Group2: ICRC7, ICRC37
  // Group1 CAN appear together
  // Group2 CAN appear together
  // Group1 and Group2 CANNOT appear together in the same token spec. 
  // An Inventory containing a dual type token CAN be created by using separate token specs from Group 1 and Group 2. See Ask Features

};
```

#### ICRC-1 Token Standard Detail (ICRC1TokenSpecDetail)

`ICRC1TokenSpecDetail` provides specific details for tokens that follow the ICRC-1 standard, including the total amount and the optional fee associated with the token transaction, alongside the token's decimal precision.

```candid
type ICRC1TokenSpecDetail = record {
  amount: Nat;      // The amount of the token involved
  fee: opt Nat;     // An optional fee for the token transaction
  decimals: Nat;    // The decimal precision of the token
};
```

#### ICRC-2 Token Standard Detail (ICRC2TokenSpecDetail)

`ICRC2TokenSpecDetail` extends `ICRC1TokenSpecDetail` with additional fields specific to the ICRC-2 standard, such as `approval_fee` and `transfer_from_fee` which represent specific fee types relevant for this standard. Choosing to provide ICRC2 instead of ICRC1 can streamline settlements because the settling ledger is able to pull the items from other ledgers without the maket participant having to send the assets to the escrow account of the settling ledger first.

```candid
type ICRC2TokenSpecDetail = record {
  amount: Nat;               // The amount of the token involved
  approval_fee: opt Nat;     // An optional fee for approving token transactions
  transfer_from_fee: opt Nat; // An optional fee for executing the transfer_from operation
  decimals: Nat;             // The decimal precision of the token
};
```

#### ICRC-4 Token Standard Detail (ICRC4TokenSpecDetail)

`ICRC4TokenSpecDetail` is tailored for batch operations as defined by the ICRC-4 standard, which includes a `batch_fee` for processing multiple transactions together.  ICRC4 can streamline settlements to multiple accounts and the payment of fees and royalties to multiple participants in one transaction.

```candid
type ICRC4TokenSpecDetail = record {
  batch_fee: opt Nat; // An optional fee for batch processing of token transactions
  decimals: Nat;      // The decimal precision of the token
};
```

#### ICRC-7 Token Standard Detail (ICRC7TokenSpecDetail)

`ICRC7TokenSpecDetail` focuses on specifications related to non-fungible tokens (NFTs) following the ICRC-7 standard. It includes an optional fee and a list of `token_ids` to indicate specific NFTs being worked with.

```candid
type ICRC7TokenSpecDetail = record {
  fee: opt TokenSpec;  // An optional fee, represented as another TokenSpec
  token_id: ?Nat;      // A token IDs for NFT identification. Empty means any token in the ledger will satisfy.
};
```

#### ICRC-37 Token Standard Detail (ICRC37TokenSpecDetail)

`ICRC37TokenSpecDetail` combines aspects of both fungible (ICRC-1) and non-fungible (ICRC-7) token standards, supporting features such as approvals, token transfers with `transfer_from`, and operations on specific NFTs identified by their `token_ids`.

```candid
type ICRC37TokenSpecDetail = record {
  approval_fee: opt TokenSpec;      // An optional fee for approvals, using another TokenSpec
  transfer_from_fee: opt TokenSpec; // An optional fee for transfer_from operations, using another TokenSpec
  token_id: ?Nat;                   // A token IDs for NFT identification. Empty means any token in the ledger will satisfy
};
```

Together, these data types form a detailed specification of tokens that may interact within an ICRC-8 marketplace. They provide a bounded and extensible framework that ensures the proper functionality and compatibility of diverse token standards within the Internet Computer ecosystem.

The `TokenSpecResult` captures the outcome of operations on tokens, such as transfers or settlement processes. It extends the `TokenSpec` with additional information about the transaction outcome, including accounts involved (`sending_account` and `receiving_account`), references to any source ask responsible for the operation (`ask_id`), and the transaction result in the form of a list of natural numbers (`result`), which match against token IDs or fungible token amounts.

```candid
type TokenSpecResult = record {
  TokenSpec with
  result: Nat; // Transaction Index
  sending_account: Account;
  receiving_account: Account;
  ask_id: opt Nat;
};
```

### Escrow Record (EscrowRecord)

An `EscrowRecord` represents an item or a set of items placed into escrow pending completion of a transaction. It details the transaction type (bid or ask), the accounts of the buyer and seller, the specific tokens offered for sale (`ask_token`) or bid (`bid_token`), a specific ask identifier (`ask_id`), and an optional date until which the escrow is valid (`lock_to_date`). This structure is essential for holding assets securely until transaction conditions are met.

```candid
type EscrowRecord = record {
  type: variant {
    bid: vec (opt TokenSpec); //Defines the items in or to be put in escrow for the bid
    ask: vec (opt TokenSpec); //Defines the items in or to be put in escrow for the ask
    settlement: vec (opt TokenSpec); //Defines the items in escrow for settlement
  }; //settlement is used for records used for settlement that allow the owner of proceeds to withdraw if automatic distribution is not enabled or fails.
  buyer: opt Account; //a null buyer means that the escrow can be used in any transaction with any market participant provided other settlement criteria are met.
  seller: Account; 
  ask_id: opt Nat; //restricts the escrow to be used for a particular ask
  lock_to_date: opt Nat64; //will lock the escrow so that it cannot be withdrawn before a set date. Useful for sales that require upfront deposits by buyers
};
```

### AskFeature Data Type

The `AskFeature` data type represents various aspects of a seller's listing on the marketplace. Each variant of `AskFeature` reflects a specific option or requirement that can define behavior or conditions of the ask (the seller's offer on the marketplace). Below is the candid definition for each variant supported in ICRC-8, together with descriptions of their purposes and usage in a marketplace context.

When creating an ask, the market participant will provide a vector(Array) of these items if they are necessary to the restrictions of the ask.

```candid
type AskFeature = variant {
  allow_partial;
  unsolicited_offer: Account;
  buy_now : vec vec BuyNowReq;
  allow_list : vec Account;
  broker : Account;
  start_date : Nat64;
  ending : variant {
    perpetual;
    date : Nat64;
    timeout : Nat64;
  };
  ask_token : vec opt TokenSpec;
  fee_schema : Text;
  fee_accounts : vec (tuple { FeeName; TokenSpec; Account });
  bid_pays_fees : opt vec FeeName;
  created_at : Nat64;
  memo : Blob;
};
```

#### Components of AskFeature

- `ask_token`: Required - A list of token specifications representing the assets or tokens being offered for sale. These token specifications must include the token canister, symbol, and relevant standards.

- `buy_now`: Required - Defines one or more sets of token specifications and quantities that, when met by a bid, will trigger an immediate sale. The `buy_now` feature facilitates the fixed-price sale of items. Note: Only required for core ICRC8 transactions. Auctions types covered in future ICRCs may make this no longer required.

- `allow_partial`: Optional - Indicates whether the seller is open to selling a portion of the listed inventory. Useful in scenarios where the seller has multiple similar items or tokens and is willing to transact on them individually or in smaller groups. Only applicable to 1:1 Fungible tokens where ONE Fungible token is being traded for ONE OTHER fungible token. The ratio is 1:1 for fulfillment. See AMM for more complicated token swap ask types.

- `allow_list`: Optional - A list of accounts that are allowed to participate in the transaction. This provides a way to create private or restricted sales. If not provided the sale is open to anyone.

- `broker`: Optional - The account of a broker, if any, who is involved in the transaction. Brokers can facilitate the transaction and may earn commissions for their services.

- `start_date`: Optional - A timestamp indicating when the ask becomes active. Before this time, the ask can be visible but not actionable. If not provided, the ask SHOULD become immediately available

- `ending`: Optional - Specifies how the ask comes to an end. The `ending` feature ensures that a listing can be perpetual, expire on a specific date, or end after a certain timeout period since the start of the ask. If the ending is not provided the implementation MAY set a default ending timeout that SHOULD be published in the icrc8:default_ask_timeout metadata section. Nanoseconds.

- `fee_schema`: Optional - A text identifier that references a predefined fee structure to be applied to the transaction. Marketplaces may offer multiple fee structures to suit different seller preferences. If not provided the implementation may choose a default fee schema if applicable and SHOULD be published in the icrc8:default_fee_schema metadata section. 

- `fee_accounts`: Optional - Associates specific fees identified by `FeeName` with token specifications and designated accounts for fee collection. This component dictates where and how fees are levied and collected. Fees may be taken out of the proceeds if the fee accounts are not provided. Fee accounts should be accounts that market participants have deposited on the market canister's assigned subaccount.

- `bid_pays_fees`: Optional - Optionally specifies which fees a bidder is responsible for paying as part of the transaction. If absent, the seller assumes responsibility for all fees.

- `unsolicited_offer`: Optional - If this is an unsolicited offer, provide this to have it filed with the users account. A future ICRC should provide a filtering mechanism that can keep a user from being spammed.

- `created_at`: Optional - A timestamp used to deduplicate any transactions and ensure idempotency within a certain window. This timestamp is especially crucial for asynchronous or batched operations that may be retried due to network conditions.

- `memo`: Optional - An arbitrary blob of data, typically used for additional transaction information that the seller or marketplace wishes to associate with the ask.


### Why and How AskFeature Components are Used

The components of `AskFeature` collectively describe various configurations and constraints a seller may impose on their offer within the marketplace. By encapsulating these options, `AskFeature` allows for a customizable and flexible approach to creating listings. Sellers can tailor their asks to suit their preferences, whether in pricing strategy (`buy_now`), market exposure (`allow_list`), sales strategy (`allow_partial`), and time-limited offers (`start_date`, `ending`). 

Additionally, `AskFeature` allows for clear delineation of financial responsibilities (`fee_schema`, `fee_accounts`, `bid_pays_fees`) and accommodates the involvement of third parties (`broker`). The deduplication (`created_at`) and additional information (`memo`) are critical for maintaining state consistency and providing context. 

As developers build marketplaces using ICRC-8, they can utilize and extend `AskFeature` to create a bespoke trading experience that aligns with their platform's objectives, user needs, and regulatory environment while leveraging the robustness and security of the Internet Computer's infrastructure.

The following Standards are Published alongside ICRC8 to provide a robust set of market options

#### ICRC-61: Standard Auctions for Ledger Native Markets

The features introduced by ICRC-61 extend marketplace behavior to include auctions within ledger-native markets, providing mechanisms for setting reserve prices, initiating auctions, defining starting prices, and specifying minimum incremental bids.

- `auction_token`: Specifies the token in which the auction will be conducted.
  
- `wait_for_quiet`: An extension mechanism for auctions, where the closing time extends if there are bids within a certain window before the scheduled end.
  
- `reserve`: The minimum reserve price that the seller is willing to accept for the asset.
  
- `start_price`: The price at which the auction starts.
  
- `min_increase`: The minimum required increment for subsequent bids over the current leading bid.

```candid
type AuctionFeature = variant {
  auction_token : TokenSpec;
  wait_for_quiet : WaitQuietParams;
  reserve : Nat;
  start_price : Nat;
  min_increase : MinIncrease;
};

type WaitQuietParams = record {
  window : Nat64;
  extension : Nat64;
  fade : Float;
  max : Nat; //maximum number of resets
};

type MinIncrease = variant {
  percentage : Float;
  amount : Nat;
};
```

#### ICRC-62: AMMs for Ledger Native Markets

ICRC-62 introduces `AskFeature` extensions for leveraging Automated Market Makers (AMMs) in ledger-native markets. This allows for dynamic pricing based on liquidity pools and trade volumes.

- `amm`: Defines the automated market-making parameters for the listing, specifying token pairs and their associated parameters.

```candid
type AMMFeature = variant {
  amm : AMMParams;
};

type AMMParams = record {
  token_1 : TokenSpec;
  token_2 : TokenSpec;
  max : Nat;
  min : Nat;
  decimals : Nat;
};
```

#### ICRC-63: Dutch Auctions for Ledger Native Markets

Dutch auctions reduce the sale price over time until a buyer accepts the current price. ICRC-63 adds functionality to marketplaces for sellers wishing to use this auction type.

- `dutch`: Parameters defining how the Dutch auction will function, including the step at which the price decays and the nature of the decay.

```candid
type DutchAuctionFeature = variant {
  dutch : DutchParams;
};

type DutchParams = record {
  time_unit : TimeUnit;
  decay_type : DecayType;
};

type TimeUnit = variant {
  hour : Nat;
  minute : Nat;
  day : Nat;
};

type DecayType = variant {
  flat : Nat;
  percent : Float;
};
```

#### ICRC-64: Elective KYC for Ledger Native Markets

ICRC-64 provides a feature to ensure Know Your Customer (KYC) procedures can be selectively enforced in a marketplace or on a particular sale.

- `icrc17_kyc`: Specifies the principal of an ICRC-17-compliant KYC provider to use for vetting any buyers.

```candid
type KYCFeature = variant {
  icrc17_kyc : Principal;
};
```

#### ICRC-64: Temporal Locks for Ledger Native Markets

This feature allows for creating listings that can be time-locked for shore periods via fee payment, providing assurance to matching engines and other services to pay for the right to execute for a particular amount of time.

- `no_lock`: Denotes that a listing is immune to temporal locks imposed by fee structures.

```candid
type NoLockFeature = variant {
  no_lock;
};
```

#### ICRC-71: Market Notifications

To accommodate the instant update or alert mechanisms for market participants, ICRC-71 introduces notification capabilities.

- `notify`: An array of principals to notify when a significant event occurs, such as a sale or bid placement.

```candid
type NotifyFeature = variant {
  notify : vec Principal;
};
```

### AskStatus Data Type

The `AskStatus` data type represents the current state of an ask (an offer to sell) on the marketplace. It contains detailed information about the ask's condition, transaction specifics, and its position within the settlement process. `AskStatus` helps track asks from their creation to the final settlement or removal. The following represents the Candid definition of `AskStatus`:

```candid
type AskStatusShared = record {
    ask_id : Nat;
    original_broker_id : opt Account;
    current_broker_id : opt Account;
    config : [AskFeature]; 
    auction_info: opt AuctionInfo;
    settlement: opt SettlementInfo;
    allow_list : opt vec Account;
    participants : vec Account;
    settled_at : opt (Principal, Nat);
    status : AskStatusType;
    seller : Account;
};

type AuctionInfo = record {
    token : TokenSpec;
    current_bid_amount : opt Nat;
    end_date : opt Nat64;
    start_date : opt Nat64;
    min_next_bid : opt Nat;
    wait_for_quiet_count : opt Nat;
    current_escrow : opt EscrowRecord;
};

type SettlementInfo = record {
    bid_tokens: vec opt TokenSpecResult;
    ask_tokens: vec opt TokenSpecResult;
    royalties : vec (tuple {Account; Nat; Text});
};

type AskStatusType = variant {
    open;
    closed;
    encumbered : vec EncumbranceDetail;
    not_started;
};
```

#### Components of AskStatus

- `ask_id`: A unique identifier for the ask, allowing efficient tracking and referencing.
  
- `original_broker_id`: Optional account of the initial broker involved in creating the ask.
  
- `current_broker_id`: Optional account of the current broker responsible for the bid side if a bid or sale has occured.
  
- `config`: Shared configuration details of the ask, encapsulating common settings and constraints. The AskFeature List provided to create the ask

- `auction_info`: Optional record holding information if the ask is part of an auction. It includes token details, bid amounts, auction timing, and current escrow status.

- `settlement`: Optional information detailing the settlement process. It includes the tokens from the bid, tokens from the ask, and any royalties due to associated parties.

- `allow_list`: An optional list of approved accounts that can participate in the ask.

- `participants`: A list of accounts that have participated in the ask, useful for maintaining the ask's history or enforcing certain rules.

- `settled_at`: Optional details of where the settlement occurred, identified by the canister Principal and the specific ask ID it relates to.

- `status`: The current status of the ask, represented by the `AskStatusType` variant.

- `seller`: The account of the seller, which remains fixed and is tied to the ownership of the tokens or assets being sold.

#### Usage and Purpose of AskStatus Components

The `AskStatus` components collectively provide a complete picture of each ask's lifecycle in the marketplace. By articulating various states (`status`), tracking progress (`auction_info`, `settlement`), and specifying conditions (`config`, `allow_list`), `AskStatus` facilitates the management and execution of trades on the ICRC-8 ledger. It acts as a centralized source of truth for all relevant details, supporting transparency and efficiency within the marketplace.

Marketplace developers and participants can leverage `AskStatus` to query the current condition of any ask, make informed decisions based on participation (`participants`), broker activity (`original_broker_id`, `current_broker_id`), and verify the finality of transactions (`settled_at`). It plays a vital role in ensuring that marketplace functions correctly, transactions occur without dispute, and all parties are adequately informed throughout the trading process.

## BidFeatures Data Type

`BidFeatures` is a data type that represents the various configurations or requirements that a buyer might specify when placing a bid within an ICRC-8 marketplace. It defines the conditions and transactional behaviors a bid may include, ensuring that bids align with the buyer's intentions and comply with the marketplace's operational rules.

Here are the candid definitions for the variants and types found within the `BidFeatures` data type, describing their functionalities and usage:

```candid
type BidFeatures = variant {
  broker : Account;
  escrow : EscrowRecord;
  fee_schema : Text;
  fee_account : vec (tuple { FeeName; TokenSpec; Account });
  amm : AMMParams; //see ICRC-62: AMMs for Ledger Native Markets
};
```

#### Components of BidFeatures

- `escrow`: Required - Contains the specifics of the items or funds that the buyer is willing to place as a guarantee for the bid's fulfillment.

- `broker`: Optional - An optional account for a market place or service provider to provide a broker code for collecting bid side fees.

- `fee_schema`: Optional - A text identifier for a bidder to select which fee structure they would like applied to the bid, dictating how and what kinds of fees the bidder must pay.

- `fee_account`: A list of tuples pairing a `FeeName` with its corresponding `TokenSpec` and an `Account` where a fee paid by the bidder can be collected from.

- `amm`: Optional - parameters related to automated market makers (AMM), allowing bids to be adjusted according to market conditions and slippage tolerances. This is relevant for bids within AMM-driven market environments.

By defining `BidFeatures`, ICRC-8 marketplaces empower participants to craft bids that accurately reflect their purchasing strategies, financial planning, and the desired level of involvement in the marketplace’s activities, enhancing the overall efficiency and user experience of decentralized trading on the Internet Computer.

#### EngineMatch Data Type

`EngineMatch` is a data type representing a set of matched asks, coordinated by a leader and optionally processed with asks across multiple canisters. It facilitates off-ledger matching engines that hold the potential to aggregate or match trades occurring within the ecosystem.

#### Candid Definition

```candid
type EngineMatch = record {
  leader: opt Principal;
  asks : vec {
    ask_canister: opt Principal;
    ask_id: Nat;
    token: opt vec opt TokenSpec;
  };
};
```

#### Components of EngineMatch

- `leader`: The principal ID of the leader canister, which manages the overall settlement of the matched trades. Not required for single canister matches

- `asks`: A vector of records with each entry representing an involved ask. Each ask is defined by the principal of its hosting canister (`ask_canister`)(not required for single canister matches), the unique identifier (`ask_id`), and an optional vector of token specifications (`token`). The token spec is only required if the match is applying a partial match from the ask. The vector forms the basis to satisfy an ask fully through the provided tokens.

#### Usage and Purpose

The `EngineMatch` data type is utilized when an off-ledger or an external matching engine identifies a set of asks that can be settled together, either within a single ledger or across multiple ledgers. It allows for complex trading strategies and the efficient execution of larger orders that may span several markets.

An `EngineMatch` instruction is sent to the ledger market canister (the leader) with the set of asks and the relevant token specifications. The leader canister processes this information and orchestrates the necessary transfers to fulfill the involved asks. It relies on the reliable and secure nature of the Internet Computer Protocol (ICP) to securely and atomically settle transactions in a decentralized and trustless manner.

### Example Use-Case

A matching engine finds that several asks can be fulfilled by an aggregated set of asks across multiple NFT marketplaces on the Internet Computer. It creates an `EngineMatch` record, designating one of the canisters as the leader responsible for settlement. The matching engine sends the `EngineMatch` to the leader, which then contacts the other canisters to execute the matched trades securely and atomically.

## Methods

```
public type Service = actor {
      icrc8_ask : ([?ManageAskRequest]) -> async [(?ManageAskRequest, ?ManageAskResponse)]; 
      icrc8_bid : ([?ManageBidRequest]) -> async[(?ManageBidRequest, ?ManageBidResponse)]; 

      //queries
      icrc8_balance_of : shared query (request : [(Account,?[?BalanceRequest])]) -> async [(Account, [?BalanceResult])];
      icrc8_ask_info : shared query [?AskInfoRequest] -> async [(?AskInfoRequest, ?AskInfoResponse)];
      icrc8_approved_tokens: shared composite query () -> async ?[Principal];
  };
```

### Update Methods

#### `icrc8_ask` Method

The `icrc8_ask` method represents a primary mechanism for users to manage asks within the ledger marketplace. The method allows for creating new asks, modifying existing ones, and handling settlements, providing users with a comprehensive set of operations for selling tokens or NFTs. This method supports batch processing, enabling actions on multiple asks simultaneously.

##### Definition

The `icrc8_ask` method is defined with a single input parameter: a vector of optional `ManageAskRequest` entries. Each entry within this vector corresponds to a different ask management action.

```candid
icrc8_ask : (vec opt ManageAskRequest) 
  -> async (vec (opt ManageAskRequest, opt ManageAskResponse));
```

##### Input Types

The input type `ManageAskRequest` is a variant that includes different actions related to asks. Each variant represents a specific operation, such as creation, cancellation, or update.

```candid
type ManageAskRequest = variant {
  new_ask : vec opt AskFeature;     // Create a new ask with the specified features
  end_ask : Nat;                    // End an existing ask specified by ask_id
  refresh_offers : opt Account;     // Request to refresh and check for offers made
  withdraw_settlement : EscrowRecord; // Request to withdraw funds from a settled ask
  withdraw_escrow : EscrowRecord;   // Request to withdraw funds or items from escrow
  reject_offer : Nat;               // Reject an unsolicited offer specified by ask_id
  distribute_ask : Nat;             // Distribute the proceeds from a settled ask
  update_amm : AMMUpdate;           // Update Automated Market Maker (AMM) parameters
  lock_ask : LockAsk;               // Apply a temporal lock to an ask via fee payment - ICRCXX
  unencumber : Nat;                 // Remove encumbrance from an ask
};
```

##### Output Types

The output type is a vector where each entry is a tuple consisting of an `opt ManageAskRequest` and `opt ManageAskResponse`. The `ManageAskResponse` is a variant representing the outcome of each ask action from the corresponding request.

```candid
type ManageAskResponse = variant {
  new_ask : variant { 
    Ok : NewAskResult;             // Successful response for creating a new ask
    Err : GenericError;            // Error response for ask creation failure
  }; 
  end_ask : variant { 
    Ok : Nat;                      // Tx index of a successful ask removal or settlement
    Err : GenericError;            // Error response for ask end failure
  }; 
  refresh_offers : variant { 
    Ok : record {
        records : [(Blob, ?AskStatus)];
        eof : Bool;
        count : Nat;
      };            // Successful refresh, returning updated records
    Err : GenericError;            // Error response for refresh failure
  }; 

  withdraw_settlement : variant {
    Ok: record {
      withdraw_result: Nat;
      token_results: [{
        token: TokenSpec;
        result : {
          #Ok: Nat; //trx record if successful
          #Err: GenericError
        };
      }];
    }; //trx record if successful
    Err: GenericError;
  }; 
    

  distribute_ask : record{
    Ok: vec record {
        token: TokenSpec;
        result : variant {
          Ok: Nat; //trx record if successful
          Err: GenericError
        };
      };
    Err: GenericError;
  };
  lock_ask : {
    Ok: vec TokenSpecResult; //result of distributing the lock fees
    Err: GenericError;
  };
};
  
```

##### Method Behavior Descriptions

- **Creation**: A new ask is created when `new_ask` is sent, with the system generating metadata and handling the escrow of tokens according to the features specified.

- **Cancellation/End**: An existing ask can be ended with `end_ask`. The tokens in escrow will be returned to the seller, or the settlement proceeds made available.

- **Offers**: Using `refresh_offers`, a seller can check for any external, unsolicited offers to their tokens.

- **Settlement Withdrawal**: With `withdraw_settlement`, a seller can pull their portion of the settlement from a completed ask.

- **Escrow Withdrawal**: `withdraw_escrow` lets a seller or buyer withdraw tokens or items from escrow, assuming conditions for their release are met.

- **Rejection**: A seller can reject an unsolicited offer using `reject_offer`, which will cancel the bidder's escrow.

- **Distribution**: The `distribute_ask` action allows for manual distribution of settlement funds, potentially saving on transaction fees.

- **AMM Updates**: The `update_amm` variant enables changes to AMM parameters, affecting price dynamics within an AMM-based auction or sale.

- **Locks**: `lock_ask` is used to apply time-based locks to asks, protecting against premature withdrawal and ensuring stability during matching or negotiation phases.

- **Encumbrance**: Trustees can have an ask's encumbrance removed with `unencumber`, proceeding with sale completion or availability adjustments.

#### icrc8_bid

The `icrc8_bid` method is used to manage bids within the marketplace. This method supports a variety of bid-related operations, including creating new bids, withdrawing bids from escrow, and engaging with engine matches.

##### Method Definition

```candid
icrc8_bid : (vec opt ManageBidRequest) -> async (vec (opt ManageBidRequest, opt ManageBidResponse));
```

##### Input Types

```candid

type EngineMatch = {
    leader: ?Principal;
    asks : [{
      ask_canister: ?Principal;
      ask_id: Nat;
      token: ?[?TokenSpec];
    }]; //ask ids that complete a match;
    // expires? engine_match fee?
  };

type ManageBidRequest = variant {
  new_bid : record {
    ask_id: Nat;
    feature: vec opt BidFeature;
  };

  engine_match : EngineMatch;

  withdraw_escrow : EscrowRecord;
};
```

`new_bid`: Submits a new bid request with specified bid features. The ask_id is tied to an existing ask, and the bid features provide the necessary details for the bid.

`engine_match`: Submits a request to match and settle a bid according to an externally determined match, often involving multiple asks.

`withdraw_escrow`: Requests the withdrawal of funds or assets from escrow that are associated with a bid. The EscrowRecord specifies the details of the escrowed items.

##### Output Types

```candid
type ManageBidResponse = variant {
  new_bid : variant {
    Ok : record {
      escrow : EscrowRecord;
      result: Nat; // Transaction index if successful
    };
    Err : GenericError;
  };

  engine_match : variant {
    Ok : [{
      ask_canister: ?Principal;
      ask_id: Nat;
      token: ?[?TokenSpecResult];
    }]; // Ask_ids that have been successfully encumbered or processed.
    Err : GenericError;
  };

  withdraw_escrow : variant {
    Ok : record {
      withdraw_result: Nat;
      token_results: vec record {
        token: TokenSpec;
        result : variant {
          Ok: Nat; // Transaction index if successful
          Err: GenericError;
        };
      };
    };
    Err : GenericError;
  };
};
```

`new_bid`: The response to a new bid creation request. If the operation succeeds, the response includes an updated escrow record and the transaction index. If there's an error, a `GenericError` is provided.

`engine_match`: The response for an engine match request. On success, a list of ask_ids is returned. These are the asks that were successfully coordinated for settlement in the engine match process.

`withdraw_escrow`: The response for an escrow withdrawal request, detailing the results of the withdrawal attempt for each involved token.

##### Method Behavior Descriptions

`new_bid`: When a user wishes to place a new bid on an existing ask, they instantiate a `new_bid` request. The market receives the bid and, if it meets the necessary criteria, places the specified funds or assets into escrow and updates the ask's status accordingly.

`engine_match`: Utilized by external matching engines or the leader in a multi-ask settlement process, `engine_match` requests coordinate and enact a complex bid that satisfies one or more asks, potentially across different marketplaces.

`withdraw_escrow`: Allows a bidder to withdraw their bid and retrieve their assets from escrow, assuming the bid hasn't been consummated and no standing commitments or lock periods prevent withdrawal.

### Query Methods

#### icrc8_balance_of

The `icrc8_balance_of` method is a query used to determine the balance of various account-related records within the marketplace. This method can provide balances for NFTs, fungible tokens, assets in escrow, and details on settlements and offers associated with a particular account. It is meant as a replacement for either icrc1_balance_of and icrc7_balance_of.

##### Method Definition

```candid
icrc8_balance_of : shared query (
  request : vec (Account, opt BalanceRequest)
) -> async vec (Account, vec BalanceResult);
```

##### Input Types

```candid
type BalanceRequest = variant {
  nfts : opt record {
    prev: opt Nat;
    take: opt Nat;
  };
  tokens : null;
  escrow : opt record {
    prev: opt Nat;
    take: opt Nat;
  };
  ask_settlements : opt record {
    prev: opt Nat;
    take: opt Nat;
  };
  offers : opt record {
    prev: opt Nat;
    take: opt Nat;
  };
};
```

`nfts`: Request data for NFT balances associated with an account, with pagination support through `prev` and `take`.

`tokens`: Request the fungible token balance for an account.

`escrow`: Request data on assets or funds held in escrow, with pagination.

`ask_settlements`: Request data on settled asks, with pagination.

`offers`: Request data on offers placed for the account, with pagination.

##### Output Types

```candid
type BalanceResult = variant {
  nfts : opt record {
    records: vec EscrowRecord;
    count: Nat;
    eof: Bool;
  };
  tokens: opt Nat;
  escrow : record {
    records: vec EscrowRecord;
    count: Nat;
    eof: Bool;
  };
  ask_settlements : record {
    records: vec (EncumbranceDetail, EscrowRecord);
    count: Nat;
    eof: Bool;
  };
  offers : record {
    records: vec EscrowRecord;
    count: Nat;
    eof: Bool;
  };
};
```

`nfts`: The balance result for NFTs, including records of individual NFTs in escrow, the total count, and an end-of-file (eof) flag for pagination.

`tokens`: The balance result for fungible tokens, represented as a natural number.

`escrow`: Details on assets or funds in escrow, along with pagination information.

`ask_settlements`: Records of settled asks associated with the account, with pagination.

`offers`: Records of offers associated with the account, with pagination.


#### icrc8_ask_info

The `icrc8_ask_info` method is a query that retrieves detailed information about asks on the marketplace. Users can request data on active asks, ask history, individual ask statuses, and escrow information associated with a specific ask.

##### Method Definition

```candid
icrc8_ask_info : shared query [opt AskInfoRequest] -> async [opt AskInfoResponse];
```

##### Input Types

```candid
type AskInfoRequest = variant {
  active: opt (opt Nat, opt Nat);
  history: opt (Nat, Nat);
  status: Nat;
};
```

`active`: Request a list of active asks with pagination support.

`history`: Request a historical list of asks, typically settled or removed, with pagination.

`status`: Request the current status and details of a specific ask by its ask_id.

##### Output Types

```candid
type AskInfoResponse = variant {
  active : record {
    records: vec (opt AskStatus);
    eof: Bool;
    count: Nat;
  };
  history : record {
    records: vec (opt AskStatus);
    eof: Bool;
    count: Nat;
  };
  status : opt AskStatus;
};
```

`active`: The response for active asks, including records of each ask, pagination flags, and the count of returned records.

`history`: The response for historical ask data, with individual ask records, eof flag, and count.

`status`: Provides the current detailed status of a specific ask.

#### icrc8_approved_tokens

The `icrc8_approved_tokens` method is a composite query that provides a list of tokens approved for use within the marketplace. This information is crucial for sellers and bidders to ensure they transact with supported tokens and for matching engines to validate the compatibility of cross-canister trades.

##### Method Definition

```candid
icrc8_approved_tokens: shared composite query () -> async ?vec Principal;
```

##### Output Types

A simple optional vector of principals representing tokens approved for usage in the marketplace.

## Unsolicited Offers

In the realm of on-ledger marketplaces, unsolicited offers are bids made by potential buyers directly to asset owners without the initiation of a formal selling process by the owner itself. This feature enables fluidity and dynamism in the marketplace, allowing buyers to express interest in assets not explicitly listed for sale.

#### Operation of Unsolicited Offers

1. **Making an Offer**: Interested buyers can submit an offer for an asset, be it fungible tokens or NFTs, that they wish to acquire. This offer includes the terms the buyer is willing to accept, such as the price and any applicable conditions, encapsulated within an set of AskFeatures.

2. **Targeting the Offer**: Offers can be made to specific asset owners or open to any potential seller. If targeted, the owner's `Account` information is included in a unsolicited_offer feature so that it is recognized by the system.

3. **Awaiting Acknowledgment**: Offers are held in escrow, with the proposed assets or tokens from the bidder secured within the marketplace's system, waiting for acknowledgment from the asset owner.

4. **Owner's Response**: Asset owners have the autonomy to review unsolicited offers and can take the following actions:
    - Accept the offer, proceeding with the transaction under the offered terms with an immediate and automated settlement if contractual conditions are met.
    - Reject the offer, releasing the assets or tokens back to the bidder and ending the proposal.
    - Ignore the offer, leaving the assets or tokens in escrow until the bidder withdraws the offer or the offer expires.

5. **Expiration and Withdrawal**: Offers may come with a time limit for acceptance. Bidders can also withdraw their offers if not yet accepted, reclaiming their escrowed assets or tokens.

#### Benefits of Unsolicited Offers

- **Market Liquidity**: By allowing buyers to make offers on unlisted assets, there is a continual flow of transactional opportunities, enhancing liquidity.
- **Price Discovery**: Asset owners gain insight into the market's valuation of their assets, aiding in price discovery.
- **Potential for Surprise Sales**: Owners may benefit from unexpected sale opportunities, potentially at premium prices.
- **Seller Empowerment**: Owners retain control and are not obliged to enter negotiations, providing a non-intrusive way for buyers to express interest.

#### ICRC-8 Integration

To facilitate unsolicited offers within the ICRC-8 marketplace, the following mechanisms are proposed:

- An extension to the `AskFeature` variant, specifically `#unsolicited_offer: Account`, indicating that any bids made would automatically be considered by the specified account's owner.
- A method within the `Service` actor interface, `icrc8_bid`, which handles the management of bid-related actions, including submitting, withdrawing, and possibly refreshing unsolicited offers.
- The `icrc8_balance_of` query method reports any outstanding offers against an account, allowing asset owners to review unsolicited offers with ease.
- An adaptation of the `ManageBidRequest` type to accommodate `#reject_offer`, enabling asset owners to formally reject unsolicited offers.


## ICRC-8 Metadata Fields

The metadata attributes for ICRC-8 provide configuration details and operational guidelines for marketplaces. These metadata fields, encoded as `(text, value)` pairs, represent essential parameters for marketplace behavior, standards compatibility, and fee structures. The following is a description of the ICRC-8 metadata fields:

### General Marketplace Metadata

- `icrc8:default_auction_token` of type `TokenSpec`: The default token used for auction trades when not specified elsewhere. This defines the standard currency for auctions within the marketplace.
- `icrc8:default_ask_start_price` of type `nat`: The default starting price for an ask when not explicitly provided. It represents the minimum price at which a seller is willing to begin negotiations or auctions.
- `icrc8:default_ask_end_timeout` of type `nat`: The default timeout value for ending an ask, specifying the duration after which the ask is considered expired if not fulfilled.
- `icrc8:settlement_trustee` of type `principal` (optional): A principal designated for handling settlements. May be required for multi-ledger trades where encumbrance and coordination are involved.

### Fee and Commission Metadata

- `icrc8:supports_icrc_2` and `icrc8:supports_icrc_37` of type `Text`: Indicators (true or false) declaring whether the marketplace supports transfer-from workflows for fungible and non-fungible tokens, respectively.
- `icrc8:supports_icrc_4` of type `Text`: Indicators (true or false) declaring whether the marketplace supports batch settlement.


### Approved Tokens

- `icrc8:approved_tokens` of type `vec principal` or `principal`: Lists directly approved tokens or a principal that resolves to a service providing an up-to-date list of approved tokens.

Matching engines SHOULD consult this list to ensure that cross canister trades will be honored. Likely an DAO based canister that reviews implementations of ICRC8 will be necessary to whitelist compatible tokens. These tokens SHOULD be blackholed or DAO Horizoned.

### Support Indicators for Optional Features

Please see the definitions for optional metadata specifications in ICRC X,X,x,x,x

### Commission Schedules - TBD

- `icrc8:commission_schedule` of type `vec record { schema: text; schedule: vec record { tag: text; rate: opt vec { nat; nat }; ... } }`: Outlines different commission structures available within the marketplace, each with tags, rates, and accounts associated with particular fee types.

### Marketplace Fees Metadata

- `icrc8:ask_fee` and `icrc8:bid_fee` of type `Map { "canister": principal as blob; "amount": Nat; "decimal": Nat }`: Defines specific fees the marketplace may charge sellers (ask_fee) or buyers (bid_fee) for utilizing the platform. These fees can be independent of the fee structures associated with individual tokens.

## ICRC-3 Compatibility and Record Types

The following record types are declared for use with ICRC-3:

```
    type Account = [ blob(principal); blob(subaccount)? ];


    type ICRC8_TokenSpec = {
      "canister" : Blob;
      "symbol" : Text;
      "standard" : Array[ICRC8_Standards];
    };

    type ICRC8_TokenSpec_Result = {
      "sending_account" : Account;
      "receiving_account" : Account;
      "source_ask" : Nat?; //fulfillment may be from a set of asks
      "canister" : Blob;
      "symbol" : Text;
      "standard" : ICRC8_Standards;
      "result" : [Nat]; //should only be one trx for fungible and results should match order for nft results
    };  //one entry per result

    type ICRC8_Standards = {
      "icrc1" : ICRC8_ICRC1_TokenSpec?;
      "icrc2" : ICRC8_ICRC2_TokenSpec?;
      "icrc4" : ICRC8_ICRC4_TokenSpec?;
      "icrc7" : ICRC8_ICRC7_TokenSpec?;
      "icrc37" : ICRC8_ICRC37_TokenSpec?;
    }; //can be extended by other ICRCs

    type ICRC8_ICRC1_TokenSpec = {
      "fee" : Nat?;
      "decimals" : Nat;
      "amount" : Nat;
    };

    type ICRC8_ICRC2_TokenSpec = {
      "approval_fee" : Nat?;
      "transfer_from_fee" : Nat?;
      "decimals" : Nat;
      "amount" : Nat;
    };

    type ICRC8_ICRC4_TokenSpec = {
      "batch_fee" : Nat?;
      "decimals" : Nat;
    };

    type ICRC8_ICRC7_TokenSpec = {
      "fee" : Nat?;
      "token_id" : Nat;
    };

    type ICRC8_ICRC37_TokenSpec = {
      "fee" : Nat?;
      "token_id" : Nat;
    };

    ICRC8_Common = {
      "memo": Blob?;
      "ts": Nat?;
    };

    ICRC8_EscrowRecord = {
      "type": Text; // bid or ask
      "ask_token": [ICRC8_TokenSpec]?;
      "bid_token": [ICRC8_TokenSpec]?;
      "buyer": Account;
      "seller": Account?;
      "ask_id" : Nat?;
      "lock_to_date" : Nat?;
    };

    ICRC8_EscrowRecord_Withdraw = {
      "type": Text; // bid or ask
      "ask_token": ICRC8_TokenSpec_Result?;
      "bid_token": ICRC8_TokenSpec_Result?;
      "ask_id" : Nat?; //only for asks
    };

    ICRC8_Bid = ICRC8_Common and {
      "op": "bid";
      "escrow": EscrowRecord;
      "caller" : Principal;
      "fee_schema": Text?;
    };

    ICRC8_Ask_Settled = ICRC8_Common {
      "op": "settlement";
      "bid_token": [ICRC8_TokenSpec_Result]; 
      "ask_token": [ICRC8_TokenSpec_Result];
      "commissions": Array[ICRC8_Commission_Paid_Detail];
      //note amounts and token_ids adjusted to match the actual settlement rather than initial conditions.
      "caller" : Principal;
      "engine_match" : Text? - True or false; //necessary?
      "ask_id" : Nat;
    };

    ICRC8_Ask_Removed = ICRC8_Common {
      "op": "settlement";
      "seller": Account;
      "ask_id" : Nat;
    };

    ICRC8_Ask_Created = ICRC8_Common and {
      "op": "ask";
      "caller" : Principal;
      "allow_partial" : Blob?;
      "broker" : Account?;
      "buy_now" : Nat?;
      "wait_for_quiet: Map{
        "window" : Map;
        "extension" : Nat;
        "fade" : Blob; //Float as Blob
        "max" : Nat;
      }?;
      "allow_list" : Array[Account]?;
      "notify" : Array[Principal]?;
      "reserve" : Nat?;
      "start_date" : Nat?;
      "start_price" : Nat?;
      "min_increase" : Map {
        "amount" : Nat?;
        "percent" : Blob?; Float as Blob
      }?;
      "ending" : Nat?;
      "inventory" = Array[ICRC8_TokenSpec]?;
      "auction_token" = ICRC8_TokenSpec?;
      "dutch" = DutchParams;
      "icrc17_kyc" = Blob; //principal
      "ask_pays_fees_schema" = Text?;
      "ask_pays_fees_account" = Account?;
      "existing_escrow" = EscrowRecord;
      "seller": Account;
      "ask_token": [ICRC8_TokenSpec];
      "ask_id" : Nat;
    };

    ICRC8_Dutch_Params = {
      "unit" : Text; //hour, minute, day
      "decay_flat": Nat;
      "decay_percent": Blob; //as float
    };

    ICRC8_Bid_Created = ICRC8_Common and {
      "op": "bid";
      "caller" : Principal;
      "broker" : Account?
      "escrow" : ICRC8_Escrow_Record;
      "ask_id" : Nat;
    };

    ICRC8_Escrow_Created = EscrowRecord with {
      "op": "escrow_created";
      "caller": Account;
    };

    ICRC8_Escrow_Withdraw = EscrowRecordResult with {
      "op": "escrow_withdraw";
      "caller": Account;
    };

    ICRC8_Sale_Withdraw = EscrowRecordResult with {
      "op": "sale_withdraw";
      "caller": Account;
    };

    ICRC8_Commission_Paid_Detail = {
      "commission_token": ICRC8_TokenSpec;
      "receiver": Account;
      "tag" : Text;
      result : Nat;
      "ask_id": Nat;
    };

    ICRC8_Encumbered = ICRC8_Common and {
      "op" : "encumbered"
      "trustee" : Principal;
      "expires_at" : Nat;
      "ask_id" : Nat;
    };

    ICRC8_Commission_Paid = ICRC8_Common  and ICRC8_Commission_Paid_Detail and {
      "op": "commission_paid";
      "result" : Nat; //trx id on token ledger
    };


```

