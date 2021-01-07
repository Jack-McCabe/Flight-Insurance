pragma solidity ^0.4.25;


import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    
    mapping(address => Airlines) approvedAirlines; // need to move below
    mapping(string => Flights) flights; //uint will equal the flightNum
    mapping(address => bool) authCallers; //authorized callers
    

    struct Flights {
        bool isRegistered;
        address airline;
        string flightNum;
        string departureCity;
        string arrivalCity;
        uint64 departureTime;
        mapping(address => uint) insurPurch; //when they buy insurance 
    }
 

    struct Airlines{
        address airline;
        bool isRegistered;
        bool isFunded;
        uint funds;
    }
    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;

    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireAuthorizedCallers(){
        require(authCallers[msg.sender]== true, "Caller not authorized" );
        _;
    }
    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

///putting in Authorized Caller
    function authorizeCaller(address _address) external{
         authCallers[_address] = true;
    } 
   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (address airline, uint intialFunds
                            )
                            external
                            
    {return;
       // require(!approvedAirlines[airline].isRegistered, "Airlines is already registered"); //undefined! equal false 
      //  require(intialFunds >= 10, "Need to deposit at least 10 ether to register");
     //    Airlines memory newAir =  Airlines (airline, true, true, intialFunds);
      //  approvedAirlines[airline]=newAir;
    }
    


   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (string flightNum, address airAddress                      
                            )
                            external
                            payable 
    {
        require(flights[flightNum].isRegistered == true, "Flight not registered");
        flights[flightNum].insurPurch[msg.sender]= msg.value;
        approvedAirlines[airAddress].funds = approvedAirlines[airAddress].funds + msg.value;

      
    }

    
   

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees(string flightNum
                                )
                                external
                                payable
    {
        require(flights[flightNum].insurPurch[msg.sender]!=0, "No insurance bought");
                
        address addy = msg.sender;
        // need a pay function here
       // methods.pay(flightNum, addy);
    }
     
    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (string flightNum, address adddress
                            )
                            external
                            payable
    {
       uint  amount = flights[flightNum].insurPurch[adddress];
       flights[flightNum].insurPurch[adddress] = 0;
       approvedAirlines[adddress].funds = approvedAirlines[adddress].funds - amount; //Need TO CHECK if address is correct
       adddress.transfer(amount);

    }
  
    
    



   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (uint amount, address airlinesAddress
                            )
                            public
                            payable
    {
        require(approvedAirlines[airlinesAddress].isRegistered == true, "Airlines not approved");
        approvedAirlines[airlinesAddress].funds = approvedAirlines[airlinesAddress].funds+amount; 

    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund(3, msg.sender);
    }


}

