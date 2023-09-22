module {

  public type Account = {
    owner : Principal;
    sub_account: ?Blob;
  };

  public type BalanceResult = {
    nfts : [Text];
    escrow : [EscrowRecord];
    offers : [EscrowRecord];
  };

  public type EscrowRecord = {
    amount: Nat;
    buyer: Account; 
    seller: Account; 
    token_ids: [Text]; //[] any token
    token: TokenSpec;
    sale_id: ?Text; //locks the escrow to a specific sale
    lock_to_date: ?Int; //locks the escrow to a timestamp
    account_hash: ?Blob; //sub account the host holds the funds in
  };

  public type TokenSpec = {
    #ic: ICTokenSpec;
    #extensible : ICRC16.SharedValue; //#Class
  };

  public type ICTokenSpec = {
      canister: Principal;
      fee: ?Nat;
      symbol: Text;
      decimals: Nat;
      id: ?Nat;
      standard: {
          #DIP20;
          #EXTFungible;
          #ICRC1; //attempt to query balance of escrow account to recognize escrow
          #ICRC2; //attempt to use transferFrom to complete the deposit into escrow
          #Other : ICRC16.SharedValue;
      };
    };

  public type CollectionFieldRequest = {
    #logo;
    #name;
    #symbol;
    #total_supply;
    #owner;
    #managers;
    #network;
    #token_ids : (?Nat, ?Nat); //skip, take;
    #token_id_count;
    #metadata : (?Text); //CandyPath;
    #allocated_storage;
    #available_storage;
    #created_at;
    #upgraded_at;
    #unique_holders : (?Nat, ?Nat);
    #unique_holder_count;
    #transaction_count;
  };

  public type CollectionFieldResponse = {
    #logo: Text;
    #name: Text;
    #symbol: Text;
    #owner: Account;
    #managers: [Account];
    #network: Principal;
    #token_ids : [Text]; //skip, take;
    #token_id_count: Nat;
    #metadata : ICRC16.SharedValue; //CandyShared;
    #allocated_storage : Nat;
    #available_storage : Nat;
    #created_at : Int;
    #upgraded_at : Int;
    #unique_holder_count : Nat;
    #unique_holders : [Account];
    #transaction_count : Nat;
  };

  public type CollectionFieldUpdateRequest = {
    #logo: Text;
    #name: Text;
    #symbol: Text;
    #owner: Account;
    #managers: [Account];
    #network: Principal;
    #metadata : ICRC16.SharedValue; //CandyShared;
  };

  public type CollectionFieldUpdateReponse = {
    #logo: Result<Bool, ICRC8Error>;
    #name: Result<Bool, ICRC8Error>;
    #symbol: Result<Bool, ICRC8Error>;
    #owner: Result<Bool, ICRC8Error>;
    #managers: Result<Bool, ICRC8Error>;
    #network: Result<Bool, ICRC8Error>;
    #metadata : Result<Bool, ICRC8Error>;
  };

  //from ICRC3
  public type Value = { 
    #Blob : Blob; 
    #Text : Text; 
    #Nat : Nat; // do we need this or can we just use Int?
    #Int : Int;
    #Array : [Value]; 
    #Map :[(Text, Value)]; 
  };

  /*Schemas
    type Account = [ blob(principal); blob(subaccount)? ];

    type ICRC8_IC_TokenSpec = {
      canister: Blob
      name: Text; //ICRC1; ICRC2; EXTFungible; DIP20;
      fee: Nat?
      symbol: Text;
      decimal: Nat;
      id: Nat?; //for multi token canisters
    };

    type ICRC8_tokenSpec = {
      type: Text; //default is ic.  Leave available for ETH or BTC
      value: Map;
    };
    
    ICRC8_Common = {
      "token_id": Nat;
      "memo": Blob;
      "ts": Nat?;
      "ex": Value; //extensible
    };

    ICRC8_Market_Actors = {
      "buyer": Account;
      "seller": Account;
    };

    ICRC8_Auction_Bid = ICRC8_Common and ICRC8_Market_Actors and ICRC8_tokenSpec and {
      "op": "auction_bid";
      "amount": Nat;
      "sale_id": Nat;
    };

    ICRC8_Mint = ICRC8_Common and {
      "op": "mint";
      "from": Account
      "to": Account;
      //amount and token are null if it was not a sale for value
      "token": ICRC8_tokenSpec?
      "amount": Nat?;
    };

    ICRC8_Sale_Ended = ICRC8_Common and ICRC8_Market_Actors and ICRC8_tokenSpec {
      "op": "sale_ended";
      "amount": Nat?;
      "sale_id": Nat?;
    };

    ICRC8_Royalty_Paid = ICRC8_Common and ICRC8_Market_Actors and ICRC8_tokenSpec {
      "op": "royalty_paid";
      "receiver": Account;
      "tag": Text;
      "amount": Nat?;
      "sale_id": Nat?
      };

    //todo....rest of transactions
      
  */
  public type TransactionRecord = {
      token_id: Text;
      index: Nat;  //index for this token
      collection_index: Nat; //index for the entire collection
      caller: Principal;
      txn_type: {
          
          #sale_opened : {
              pricing: PricingConfigShared;
              sale_id: Text;
              extensible: ICRC16.SharedValue;
          };
          #owner_transfer : {
              from: Account;
              to: Account;
              extensible: ICRC16.SharedValue;
          }; 
          #escrow_deposit : {
              seller: Account;
              buyer: Account;
              token: TokenSpec;
              token_id: Text;
              amount: Nat;//Nat to support cycles
              trx_id: TransactionID;
              extensible: ICRC16.SharedValue;
          };
          #escrow_withdraw : {
              seller: Account;
              buyer: Account;
              token: TokenSpec;
              token_id: Text;
              amount: Nat;//Nat to support cycles
              fee: Nat;
              trx_id: TransactionID;
              extensible: ICRC16.SharedValue;
          };
          #library_staged : {
              token_id: TokenID;
              hash: ?[Nat8];
              library_id: Text;
              content_size: Nat;
              extensible: ICRC16.SharedValue;
          };
          #library_routed : {
              token_id: TokenID;
              hash: ?[Nat8];
              library_id: Text;
              content_size: Nat;
              container: Principal;
              extensible: ICRC16.SharedValue;
          };
          #sale_withdraw : {
              seller: Account;
              buyer: Account;
              token: TokenSpec;
              token_id: Text;
              amount: Nat; //Nat to support cycles
              fee: Nat;
              trx_id: TransactionID;
              extensible: ICRC16.SharedValue;
          };
          #canister_owner_updated : {
              owner: Principal;
              extensible: ICRC16.SharedValue;
          };
          #canister_managers_updated : {
              managers: [Principal];
              extensible: ICRC16.SharedValue;
          };
          #canister_network_updated : {
              network: Principal;
              extensible: ICRC16.SharedValue;
          };
          #data : {
            token_id: TokenID;
            data_path: ?Text;
            hash: ?[Nat8];
            extensible: ICRC16.SharedValue;
          }; //nyi
          #permissions_updated : {
            token_id: TokenID;
            data_path: ?Text;
            new_value: ICRC16.SharedValue;
            extensible: ICRC16.SharedValue;
          }; //nyi
          #burn: {
            from: ?Account;
            extensible: ICRC16.SharedValue;
          };
          #extensible : ICRC16.SharedValue;
      };
      timestamp: Int;
  };

  public type NFTInfoStable = {
      current_ask : ?AskStatusShared;
      current_offers: ?[EscrowRecord];
      metadata : ICRC16.SharedValue;
      transaction_count: Nat;
  };

  public type NFTFieldRequest = {
    #current_ask;
    #current_offers : (?Nat, ?Nat); //skip, take
    #metadata: Text; //candypath
    #transaction_count;
    #transactions: (?Nat, ?Nat);
    #owner;
    #managers;
    #allocated_storage;
    #available_storage;
    #minted_date;
    #burned_date;
  };

  public type NFTFieldResponse = {
    #current_ask : ?AskStatusShared;
    #current_offers : (?[EscrowRecord], Nat); //list, total_count
    #metadata: ICRC16.SharedValue; 
    #transaction_count: Nat;
    #transactions: (?[TransactionRecord], Nat);
    #owner : Account;
    #managers : [Account];
    #allocated_storage : Nat;
    #available_storage : Nat;
    #minted_date : Int;
    #burned_date : Int;
  };

  public type AskStatusShared = {
      ask_id : Blob;
      original_broker_id : ?Account;
      token_id : Text;
      config : AskConfigShared;
      current_bid_amount : Nat;
      current_broker_id : ?Principal;
      end_date : Int;
      start_date : Int;
      min_next_bid : Nat;
      token : TokenSpec;
      current_escrow : ?EscrowReceipt;
      wait_for_quiet_count : ?Nat;
      allow_list : ?[(Account, Bool)]; // user, tree
      participants : [(Account, Int)]; //user, timestamp of last access
      status : {
          #open;
          #closed;
          #not_started;
      };
      winner : ?Account;
  };

  public type StorageInfoRequest = {
    #allocated_storage;
    #available_space;
    #allocations :(?Nat, ?Nat);
    #gateway;
  };

  public type StorageInfoResponse = {
      #allocated_storage : Nat;
      #available_space : Nat;
      #allocations : (?[AllocationRecordStable], Nat); //list, total count
      #gateway : Principal;
  };


  public type StorageUpdateRequest = {
    #add_container : Principal;
  };

  public type StorageUpdateResponse = {
    #add_container : Principal;
  };

  public type EscrowReceipt = {
    amount: Nat; //Nat to support cycles
    seller: Account;
    buyer: Account;
    token_ids: [Text]; // empty string is available for any token_id
    token: TokenSpec;
  };

  public type AskConfigShared = ?[AskFeature];

  public type AskFeature = {
    #atomic;
    #broker: Princpal;
    #buy_now: Nat;
    #wait_for_quiet: {
        extension: Nat64;
        fade: Float;
        max: Nat
    };
    #allow_list : [Account];
    #notify: [Principal];
    #reserve: Nat;
    #start_date: Int;
    #start_price: Nat;
    #min_increase: {
      #percentage: Float;
      #amount: Nat;
    };
    #ending: {
      #date: Int;
      #timeout: Nat;
    };
    #token: TokenSpec;
    #token_ids: [Text];
    #dutch: DutchParams;
    #icrc17_kyc: Principal;
    #escrow_receipt: EscrowReceipt;  //used for primary sales for seller to ask to fulfill an escrowed amount.
  };

  public type DutchParams = {
    time_unit: {
      #hour : Nat;
      #minute : Nat;
      #day : Nat;
    };
    decay_type:{
      #flat: Nat;
      #percent: Float;
    };
  };

  public type SaleInfoRequest = {
    #active : ?(Nat, Nat); //get al list of active sales
    #history : ?(Nat, Nat); //skip, take
    #status : Blob; //saleID
    #escrow_info : EscrowReceipt;
  };

  public type SaleInfoResponse = {
    #active : {
        records : [(Blob, ?AskStatusShared)];
        eof : Bool;
        count : Nat;
    };
    #history : {
        records : [?AskStatusShared];
        eof : Bool;
        count : Nat;
    };
    #status : ?AskStatusShared;
    #escrow_info : SubAccountInfo;
  };

  public type SubAccountInfo = {
        owner : Principal;
        sub_account : Blob;
        encode_text : Text;
  };


  public type ChunkRequest = {
    token_id : Text;
    library_id : Text;
    chunk : ?Nat;
  };


  public type ChunkContent = {
    #remote : {
      canister : Principal;
      args : ChunkRequest;
    };
    #chunk : {
      content : Blob;
      total_chunks : Nat;
      current_chunk : ?Nat;
      storage_allocation : AllocationRecordShared;
    };
  };

  public type AllocationRecordShared = {
    canister : Principal;
    allocated_space : Nat;
    available_space : Nat;
    chunks : [Nat];
    token_id : Text;
    library_id : Text;
  };

  public type ICRC8Errors = {
    #GenericError : {
      message : Text;
      code : Nat;
    };
  };


  public type BidFeature = {
    #broker: Princpal;
    #escrow: EscrowReceipt;
    #sale_id: Blob;
  };

  public type TokenID = Text;

  public type NFTUpdate = {
    #replace: (TokenID, Path, ICRC16.SharedValue, ?ICRC16.SharedValue); //second nullable value is the expected current value and function will assert it is still the same.
    #write_permission: ICRC16.UpdateRequestShared(TokenID, Path, ICRC16.SharedValue);
    #read_permission: ICRC16.UpdateRequestShared(TokenID, Path, ICRC16.SharedValue);
    #permissions: ICRC16.UpdateRequestShared(TokenID, Path, ICRC16.SharedValue);
    #library: {
      token_id: TokenID;
      library_id: Text;
      library_data: ?ICRC16.SharedValue;
      chunk : Nat; 
      content: Blob;
    };
  };

  public type ManageSaleRequest = {
    #end_sale : TokenID; //token_id
    #recognize_escrow : EscrowRequest;
    #refresh_bids : ?Account;
    #withdraw : WithdrawRequest;
    #reject : RejectDescription;
    #distribute_sale : Account;
  };

  public type EscrowRequest{
    token: TokenSpec;
    seller: Account;
    buyer: Account;
    token_ids: [TokenID]; //[] = any token 
    amount: Nat;
    sale_id: ?Blob;
  };

  public type WithdrawRequest = {
    #escrow : WithdrawDescription;
    #sale : WithdrawDescription;
  };

  public type WithdrawDescription = {
    buyer : Account;
    seller : Account;
    token_id : Text;
    token : TokenSpec;
    amount : Nat;
    withdraw_to : ?Account;
  };

  public type RejectDescription = {
    buyer : Account;
    seller : Account;
    token_id : Text;
    token : TokenSpec;
  };

  public type ManageSaleResponse = 
    #end_sale : [(TokenID, TransactionRecord)]; //trx record if succesful
    #recognize_escrow : RecognizeEscrowResponse;
    #refresh_offers : Bool;
    #withdraw : [(TokenID, TransactionRecord)];
    #distribute_sale : [(TokenID, TransactionRecord)];
  };

  public type RecognizeEscrowResponse = {
    receipt : EscrowReceipt;
    transactions : [(TokenID, TransactionRecord)];
  };

  public type TransferArgs = record {
    spender_subaccount: ?Blob; // the subaccount of the caller (used to identify the spender)
    from : Account;
    to : Account;
    token_ids : [TokenID];
    // type: leave open for now
    memo : ?Blob;
    created_at_time : ?Nat64;
    is_atomic : ?Bool;
  };

  public type TransferError = variant {
      #Unauthorized: { token_ids : [TokenID] };
      #TooOld;
      #CreatedInFuture : { ledger_time: Nat64 };
      #Duplicate : { duplicate_of : Nat };
      #TemporarilyUnavailable;
      #GenericError :  { error_code : Nat; message : Text };
  };
  public type TransferResult =  [(TransferArgs, {#Ok : [(TokenID, TransactionRecord)]; #Err:TransferError})];

  public type ApprovalArgs =  {
      from_subaccount : ?Blob;
      spender : Account;    // Approval is given to an ICRC Account
      token_ids : ?[TokenID];            // TBD: change into variant?
      expires_at : ?Nat64;
      memo : ?Blob;
      created_at_time : ?Nat64; 
  };

  public type ApprovalError =  {
      #Unauthorized :  [TokenID];
      #TooOld;
      #TemporarilyUnavailable;
      #GenericError : { error_code : Nat; message : Text };
  };

  public type ApprovalResult =  [(ApprovalArgs, {#Ok : [(TokenID, TransactionRecord)]; #Err:ApprovalError})];

  public type TransactionResult = {
    //response mirrors icrc3
    transactions: [TransactionRecord]; //(TokenID Filter, skip, take)
    log_length: Nat;
    certificate: opt Blob;
    archived_transactions: [
      {
        args: {start: Nat; length: Nat};
        callback: query ({start: Nat; length: Nat}) -> async TransactionResult
    ]
  };

  public type Service = actor {
        icrc8_balance_of : shared query (request : [Account]) -> async [(Account, BalanceResult)];
        icrc8_owner_of : shared query [TokenID] -> async [(TokenID, Account)];
        icrc8_collection : shared query [?[CollectionFieldRequest]] -> async [(CollectionFieldRequest, CollectionFieldResponse)];  
        icrc8_history : shared query (?[TokenID], ?Nat, ?Nat) -> async TransactionResult;
        icrc8_nft_info : shared query [(TokenID, ?[NFTFieldRequest])] -> async [(TokenID, NFTFieldRequest, NFTFieldResponse)];
        icrc8_sale_info : shared query [SaleInfoRequest] -> async [(SaleInfoRequest, SaleInfoResponse)];
        icrc8_storage_info : shared query [StorageInfoRequest] -> async [(StorageInfoRequest, StorageInfoResponse)];
        icrc8_chunk : shared query [ChunkRequest] -> async [(ChunkRequest, SaleInfoResponse)];

        icrc8_token_id_to_nat : shared query [TokenID] -> async [Nat];

        http_request : shared query HttpRequest -> async HTTPResponse;
        http_request_streaming_callback : shared query StreamingCallbackToken -> async StreamingCallbackResponse;

        //update functions
        icrc8_collection_update : [CollectionFieldUpdateRequest] -> async [CollectionFieldUpdateResponse];

        icrc8_ask : [[AskRequest]] -> async [(TokenID, TransactionRecord)]; //returns (Token_ID, TransactionIndex)
        icrc8_bid : [[BidRequest]] -> async [(TokenID, TransactionRecord)]; //returns (Token_ID, TransactionIndex)
        icrc8_mint : [(Text, Account)] -> async [(TokenID, TransactionRecord)]; //returns (Token_ID, TransactionIndex)
        icrc8_nft_update: [NFTUpdate] -> async [(TokenID, TransactionRecord)];
        icrc8_add_owner: [(TokenID, Account)] -> async [(TokenID, TransactionRecord)];
        icrc8_sale : [ManageSaleRequest] -> async[(ManageSaleRequest, ManageSaleResponse)];

        //same as ICRC7 but allows for batch submission and text token ids, complex return type
        icrc8_transfer : [TransferArgs] -> async TransferResult;
        icrc8_transferFrom : [(TransferArgs)] -> TransferResult;
        icrc8_approve : [(ApprovalArgs)] -> async ApprovalResult;

        //ability to access permissioned data via https, either by query string or header. It is unlikely we can get this
        //completely secure, but we may be able to make sure that at least the secret data isn't left 'at rest' on the nod
        icrc8_access_key : (Blob) -> async Blob; //request an encrypted key that can be used to create an access token.

        //multi canister storage should maybe be its own ICRC?
        icrc8_storage_update : [StorageUpdateRequest] -> [StorageUpdateReponse];
  };

}
