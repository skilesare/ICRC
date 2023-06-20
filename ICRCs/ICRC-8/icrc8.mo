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
    token: TokenSpec;
    amount: Nat; //number of tokens
    buyer: Account; 
    seller: Account; // todo: could be null
    token_id: Text; // empty "" any token
    sale_id: ?Text; //locks the escrow to a specific sale
    lock_to_date: ?Int; //locks the escrow to a timestamp
    account_hash: ?Blob; //sub account the host holds the funds in
  };

  public type TokenSpec = {
    #ic: ICTokenSpec;
    #extensible : CandyTypes.CandyShared; //#Class
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
          #ICRC1;
          #Other : CandyTypes.CandyShared;
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

  public type TransactionRecord = {
      token_id: Text;
      index: Nat;  //index for this token
      collection_index: Nat; //index for the entire collection
      txn_type: {
          #auction_bid : {
              buyer: Account;
              amount: Nat;
              token: TokenSpec;
              sale_id: Text;
              extensible: CandyTypes.CandyShared;
          };
          #mint : {
              from: Account;
              to: Account;
              //nyi: metadata hash
              sale: ?{
                token: TokenSpec;
                amount: Nat; //Nat to support cycles
              };
              extensible: CandyTypes.CandyShared;
          };
          #sale_ended : {
              seller: Account;
              buyer: Account;
              token: TokenSpec;
              sale_id: ?Text;
              amount: Nat;//Nat to support cycles
              extensible: CandyTypes.CandyShared;
          };
          #royalty_paid : {
              seller: Account;
              buyer: Account;
              receiver: Account;
              tag: Text;
              token: TokenSpec;
              sale_id: ?Text;
              amount: Nat;//Nat to support cycles
              extensible: CandyTypes.CandyShared;
          };
          #sale_opened : {
              pricing: PricingConfigShared;
              sale_id: Text;
              extensible: CandyTypes.CandyShared;
          };
          #owner_transfer : {
              from: Account;
              to: Account;
              extensible: CandyTypes.CandyShared;
          }; 
          #escrow_deposit : {
              seller: Account;
              buyer: Account;
              token: TokenSpec;
              token_id: Text;
              amount: Nat;//Nat to support cycles
              trx_id: TransactionID;
              extensible: CandyTypes.CandyShared;
          };
          #escrow_withdraw : {
              seller: Account;
              buyer: Account;
              token: TokenSpec;
              token_id: Text;
              amount: Nat;//Nat to support cycles
              fee: Nat;
              trx_id: TransactionID;
              extensible: CandyTypes.CandyShared;
          };
          #sale_withdraw : {
              seller: Account;
              buyer: Account;
              token: TokenSpec;
              token_id: Text;
              amount: Nat; //Nat to support cycles
              fee: Nat;
              trx_id: TransactionID;
              extensible: CandyTypes.CandyShared;
          };
          #role_changed: {
            role: Text;
            principals: [Principal];
            action: {
              #add;
              #remove;
            };
          };
          #data : {
            data_dapp: ?Text;
            data_path: ?Text;
            hash: ?[Nat8];
            extensible: CandyTypes.CandyShared;
          }; //nyi
          #burn: {
            from: ?Account;
            extensible: CandyTypes.CandyShared;
          };
          #extensible : CandyTypes.CandyShared;
      };
      timestamp: Int;
  };

  public type NFTInfoStable = {
      current_ask : ?AskStatusShared;
      current_offers: ?[EscrowRecord];
      metadata : CandyTypes.CandyShared;
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
      next_dutch_timer : ?(Nat, Int);
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

  public type EscrowReceipt = {
    amount: Nat; //Nat to support cycles
    seller: Account;
    buyer: Account;
    token_id: Text; // empty string is available for any token_id
    token: TokenSpec;
  };

  public type AskConfigShared = ?[AskFeature];

  public type AskFeature = {
    #atomic;
    #buy_now: Nat;
    #wait_for_quiet: {
        extension: Nat64;
        fade: Float;
        max: Nat
    };
    #allow_list : [Principal];
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
    #dutch: DutchParams;
    #kyc: Principal;
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
        records : [(Text, ?AskStatusShared)];
        eof : Bool;
        count : Nat;
    };
    #history : {
        records : [?AskStatusShared];
        eof : Bool;
        count : Nat;
    };
    #status : ?AskStatusShared;
    #escrow_info : AccountInfo;
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


  public type Service = actor {
        icrc8_balance_of : shared query (request : [Account]) -> async [(Account, BalanceResult)];
        icrc8_balance_of_secure : shared (request : [Account]) -> async [(Account, BalanceResult)];
    
        icrc8_owner_of : shared query [Text] -> async [(Text, Account)]; // [token_id]-> [(token_id, account)];
        icrc8_owner_of_secure : shared [Text] -> async [(Text, Account)];

        icrc8_collection : shared query [?[CollectionFieldRequest]] -> async [(CollectionFieldRequest, CollectionFieldResponse)];  
        icrc8_collection_secure : shared [?[CollectionFieldRequest]] -> async [(CollectionFieldRequest, CollectionFieldResponse)];

        icrc8_history : shared query (?[Text], ?Nat, ?Nat) -> async [TransactionRecord]; //(TokenID Filter, skip, take)
        icrc8_history_secure : shared (?[Text], ?Nat, ?Nat) -> async [TransactionRecord]; //(TokenID Filter, skip, take)

        icrc8_nft_info : shared query [(Text, ?[NFTFieldRequest])] -> async [(Text, NFTFieldRequest, NFTFieldResponse)];
        icrc8_nft_info_secure : shared [(Text, ?[NFTFieldRequest])] -> async [(Text, NFTFieldRequest, NFTFieldResponse)];

        icrc8_sale_info : shared query [SaleInfoRequest] -> async [(SaleInfoRequest, SaleInfoResponse)];
        icrc8_sale_info_secure : shared [SaleInfoRequest] -> async [(SaleInfoRequest, SaleInfoResponse)];


        icrc8_storage_info : shared query [StorageInfoRequest] -> async [(StorageInfoRequest, StorageInfoResponse)];
        icrc8_storage_info_secure : shared [StorageInfoRequest] -> async [(StorageInfoRequest, StorageInfoResponse)];

        icrc8_chunk : shared query [ChunkRequest] -> async [(ChunkRequest, SaleInfoResponse)];
        icrc8_chunk_secure : shared query [ChunkRequest] -> async [(ChunkRequest, SaleInfoResponse)];

        //todo: define path standard and anti-collision mechanism.
        http_request : shared query HttpRequest -> async HTTPResponse;
        http_request_streaming_callback : shared query StreamingCallbackToken -> async StreamingCallbackResponse;

        
    };


    ///todo
    /* collection_update_nft_origyn : (ManageCollectionCommand) -> async OrigynBoolResult;
        collection_update_batch_nft_origyn : ([ManageCollectionCommand]) -> async [OrigynBoolResult];
        cycles : shared query () -> async Nat;
        get_access_key : shared () -> async OrigynTextResult;
        getEXTTokenIdentifier : shared query Text -> async Text;

        governance_nft_origyn : shared (request : GovernanceRequest) -> async GovernanceResult;
        
        http_access_key : shared () -> async OrigynTextResult;
        http_request : shared query HttpRequest -> async HTTPResponse;
        http_request_streaming_callback : shared query StreamingCallbackToken -> async StreamingCallbackResponse;

        manage_storage_nft_origyn : shared ManageStorageRequest -> async ManageStorageResult;
        market_transfer_nft_origyn : shared MarketTransferRequest -> async MarketTransferResult;
        market_transfer_batch_nft_origyn : shared [MarketTransferRequest] -> async [MarketTransferResult];
        
        mint_nft_origyn : shared (Text, Account) -> async OrigynTextResult;
        mint_batch_nft_origyn : shared (tokens : [(Text, Account)]) -> async [OrigynTextResult];
        nftStreamingCallback : shared query StreamingCallbackToken -> async StreamingCallbackResponse;
        
        update_app_nft_origyn : shared NFTUpdateRequest -> async NFTUpdateResult;
        
        share_wallet_nft_origyn : shared ShareWalletRequest -> async OwnerUpdateResult;
        sale_nft_origyn : shared ManageSaleRequest -> async ManageSaleResult;
        sale_batch_nft_origyn : shared (requests : [ManageSaleRequest]) -> async [ManageSaleResult];
        
        stage_library_nft_origyn : shared StageChunkArg -> async StageLibraryResult;
        stage_library_batch_nft_origyn : shared (chunks : [StageChunkArg]) -> async [StageLibraryResult];
        stage_nft_origyn : shared { metadata : CandyTypes.CandyShared } -> async OrigynTextResult;
        stage_batch_nft_origyn : shared (request : [{ metadata : CandyTypes.CandyShared }]) -> async [OrigynTextResult];
        storage_info_nft_origyn : shared query () -> async StorageMetricsResult;
        storage_info_secure_nft_origyn : shared () -> async StorageMetricsResult;
        transfer : shared EXTTransferRequest -> async EXTTransferResponse;
        transferEXT : shared EXTTransferRequest -> async EXTTransferResponse;
        transferFrom : shared (Principal, Principal, Nat) -> async DIP721.DIP721NatResult;
        transferFromDip721 : shared (Principal, Principal, Nat) -> async DIP721.DIP721NatResult;
        whoami : shared query () -> async Principal; */

}
