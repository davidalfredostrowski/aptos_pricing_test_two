module hello_pricing::price_oracle {
    //==============================================================================================
    // Dependencies
    //==============================================================================================
    use std::signer;
    use std::string::String;
    use aptos_framework::event;
    use std::table::{Self, Table};
    use aptos_framework::timestamp;
    use aptos_framework::account::{Self, SignerCapability};

    #[test_only]
    use aptos_framework::string;

    //==============================================================================================
    // Constants - DO NOT MODIFY
    //==============================================================================================

    // seed for the module's resource account
  const SEED: vector<u8> = b"price oracle";

    //==============================================================================================
    // Error codes - DO NOT MODIFY
    //==============================================================================================
    const ErrorCodeForAllAborts: u64 = 1238177394;

    //==============================================================================================
    // Module Structs - DO NOT MODIFY
    //==============================================================================================

    /*
        Holds price information for a specific coin pair


added 'has key'
    */
    struct Price has key, copy, store, drop {
      // the price of the pair - with 8 decimal places
                price: u128,
        // the confidence interval for the price - with 8 decimal places
        // the price is accurate within +/- confidence value
                confidence: u128
    }

    struct Counter has key { i: u64 }

     public entry fun publish(account: &signer, i: u64) {    ///public fun publish(account: &signer){

   // "Pack" (create) a Counter resource. This is a privileged operation that
      // can only be done inside the module that declares the `Counter` resource


         //prices: u128 i=3;
         move_to(account, Counter { i })
         ///move_to(account, Counter { i })
    }
   /*
        Holds price feed information for a specific price
    */
    struct PriceFeed has copy, store, drop {
        // the timestamp of when the price was attested (submitted by the admin)
        latest_attestation_timestamp_seconds: u64,
        // the id of the coin pair - e.g. "APT/USDT"
        pair: String,
        // the latest, attested price of the pair
        price: Price
    }

    /*
        table of all price feeds. To be owned by the module's resource account
    */
    struct PriceBoard has key {
        // the table mapping all coin pair ids to their price feed
        // e.g. "APT/USDT" -> PriceFeed { ... }
        prices: Table<String, PriceFeed>
    }

    /*
       Holds information to be used in the module. To be owned by the module's resource account
    */
    struct State has key {
        // the signer cap of the module's resource account
        signer_cap: SignerCapability,
        // events
        price_feed_updated_event: event::EventHandle<PriceFeedUpdatedEvent>
    }

    //==============================================================================================
    // Event structs - DO NOT MODIFY
    //==============================================================================================

    /*
        Event to be emitted when a price feed is updated
    */
    struct PriceFeedUpdatedEvent has store, drop {
        // the id of the coin pair - e.g. "APT/USDT"
        pair: String,
        // the latest, attested price of the pair
       price: Price,
        // the timestamp of when the price was attested (submitted by the admin)
        update_timestamp_seconds: u64
    }

    //==============================================================================================
    // Functions
    //==============================================================================================

    /*
        Initializes the module by creating the resource account, and setting up the State and
            PriceBoard resources
        @param admin - signer representing the oracle admin
    */
    fun init_module(admin: &signer) {
        // TODO: Create the resource account with admin account and provided SEED constant

        // TODO: Create the module's State resource and move it to the resource account
     // TODO: Create the module's PriceBoard resource and move it to the resource account
    }

    /*
        Adds or updates the price of a specified pair. This function can only be called by the
        oracle admin. Abort if the caller is not the admin.
        @param admin - signer representing the oracle admin
        @param pair - id/coin pair identifying the coin pair price being updated
        @param price - the new price scaled with 8 decimal places
        @param confidence - the interval of confidence for the price scaled with 8 decimal places
    */
   public entry fun update_price_feed(
        admin: &signer,
        pair: String,
        price: u128,
        confidence: u128
   ) {

//   ) acquires State, PriceBoard {
      move_to(admin , Price { price, confidence } )
    }

    /*
        Returns the latest price as long as it is attested within the default maximum attestation
        duration. The default maximum attestation duration is defined by the
        MAXIMUM_FRESH_DURATION_SECONDS constant. Abort if the price is stale or if the pair does
        not exist.
        @param pair - id of the coin pair being updated
        @return - the price of the pair along with the confidence
    */
   // public fun get_price(pair: String): Price acquires PriceBoard {
//
//    }
  /*
        Returns the latest price as long as it is attested no later than maximum_age_seconds ago.
        Abort if the price is stale or if the pair does not exist.
        @param pair - id of the coin pair being updated
        @param maximum_age_seconds - the maximum age of the price in seconds the request price can be
        @return - the price of the pair along with the confidence
    */
 //   public fun get_price_no_older_than(pair: String, maximum_age_seconds: u64): Price
 //   acquires PriceBoard {
 //
 //   }
//
    /*
        Returns the latest price regardless of when it was attested. Abort if the pair does not
        exist.
        @param pair - id of the coin pair being updated
        @return - the price of the pair along with the confidence, and the timestamp of when the
                    the price was attested
    */
//  public fun get_price_unsafe(pair: String): (Price, u64) acquires PriceBoard {
  //
  //  }

    //==============================================================================================
    // Helper functions
    //==============================================================================================

    //==============================================================================================
    // Validation functions
    //==============================================================================================

    //==============================================================================================
    // Tests - DO NOT MODIFY
    //==============================================================================================

    #[test(admin = @overmind, user = @0xA)]
   fun test_init_module_success(
        admin: &signer,
        user: &signer
    ) acquires State {
        let admin_address = signer::address_of(admin);
        let user_address = signer::address_of(user);
        account::create_account_for_test(admin_address);
        account::create_account_for_test(user_address);

        let aptos_framework = account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(&aptos_framework);

        init_module(admin);

        let expected_resource_account_address = account::create_resource_address(&@overmind, b"price oracle");

        assert!(exists<PriceBoard>(expected_resource_account_address), 0);
        assert!(exists<State>(expected_resource_account_address), 0);
     let state = borrow_global<State>(expected_resource_account_address);
        assert!(
            account::get_signer_capability_address(&state.signer_cap) == expected_resource_account_address,
            0
        );

        assert!(event::counter(&state.price_feed_updated_event) == 0, 0);
    }

    #[test(admin = @overmind, user = @0xA)]
    fun test_update_price_feed_success_add_one_new_pair_zero_confidence_value(
        admin: &signer,
        user: &signer
    ) acquires State, PriceBoard {
        let admin_address = signer::address_of(admin);
        let user_address = signer::address_of(user);
        account::create_account_for_test(admin_address);
        account::create_account_for_test(user_address);

        let aptos_framework = account::create_account_for_test(@aptos_framework);
        timestamp::set_time_has_started_for_testing(&aptos_framework);
       init_module(admin);

        let resource_account_address = account::create_resource_address(&@overmind, SEED);

        let pair = string::utf8(b"APT/USDT");
        let apt_usd = 691000000;
        let usdt_usd = 99880000;
        let apt_usdt = apt_usd * 100000000 / usdt_usd;
        let confidence = 0;


        update_price_feed(
            admin,
            pair,
            apt_usdt,
            confidence
        );

        let price_board = borrow_global<PriceBoard>(resource_account_address);
        let prices = &price_board.prices;
        assert!(
            table::contains(prices, pair),
            0
        );
        let PriceFeed {
            latest_attestation_timestamp_seconds: actual_attestation_timestamp,
          pair: actual_pair,
            price: Price { price: actual_price, confidence: actual_confidence }
        } = table::borrow(prices, pair);
        assert!(
            *actual_attestation_timestamp == timestamp::now_seconds(),
            0
        );
        assert!(
            *actual_pair == pair,
            0
        );
        assert!(
            *actual_price == apt_usdt,
            0
        );
        assert!(
            *actual_confidence == confidence,
            0
        );

        let state = borrow_global<State>(resource_account_address);
        assert!(event::counter(&state.price_feed_updated_event) == 1, 0);
    }
}



