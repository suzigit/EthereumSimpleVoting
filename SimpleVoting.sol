pragma solidity ^0.5.2;

import "./Ownable.sol";

contract SimpleVoting is Ownable {

  /**
   * @dev Stores the information if the some functions should be paused in case of some undesirable situation (circuit breaker).   
   */
	bool public _stopped = false;
	
    /**
   * @dev Store registered addresses (which can be verified or unverified. 
   * When verified, the elector can vote. Verified => The boolean will be true
   * After voting, the address becomes unverified. Unverified => The boolean will be false
   */    
  mapping (address => bool) private _electorAddressState;


  /**
   * @dev Stores all electorAddress already registered.
   * This variable is necessary because there is no iterator in mappings
   * 
   * NOTE: I decided not to include this variable since an external application 
   *  can monitor events and collect all electors. 
   */
//	address[] private _allElectorAddress;


  /**
   * @dev Stores the total of votes of each candidate.
   * Index 0 will store votes from option 0, index 1 will store votes from option 1 and so on.
   */
  uint[3] private _totalVotes;
  
	
  /**
   * @dev Safe mechanism check and pause the function in case of some undesirable situation (circuit breaker).   
   */
	modifier stopInEmergency { 
		require(!_stopped); 
		_; 
	}
    
  /**
   * @dev Event to inform a new vote. 
   */ 
	event VoteEvent(address indexed electorAddr, uint8 option);

    
  /**
   * @dev Event to inform a  elector was marked as verified. 
   * It will emitted both if is a new elector to be registered or if an already registered elector need to be registered 
   */ 
	event ElectorVerifiedEvent(address indexed electorAddr);


  /**
   * @dev Event to declare a winner until now, but not end the election.  
   */ 
	event DeclareWinnerEvent(bool option0, bool option1, bool option2);


  /**
   * @dev Event to informed that funds were received and returned  
   */ 
	event FundsReturnedEvent(address indexed addr, uint value);


  /**
   * @dev Create an instance of this SimpleVoting Contract.   
   */
    constructor() public {
        _totalVotes[0]=0;
        _totalVotes[1]=0;
        _totalVotes[2]=0;
    }

    /*
     * @dev This function allows the owner to mark an address as "verified"
     * @param electorAddr address of the elector
     */
    function registerAndVerifyElectorAddress(address electorAddr) stopInEmergency onlyOwner public {
        _electorAddressState[electorAddr] = true;
        emit ElectorVerifiedEvent(msg.sender);
    }


    /*
     * @dev This function allows an elector marked as "verified" to vote.
     * @param option the option to vote
     */
    function vote(uint8 option) stopInEmergency public {

        //if the sender is allowed to vote
        require (_electorAddressState[msg.sender], 'Elector not allowed to vote'); 
        require (option >= 0 && option <= 2, 'Invalid option');
        
        //If assert if false => overflow
        assert (_totalVotes[option]+1>_totalVotes[option]);

        _electorAddressState[msg.sender] = false;
        _totalVotes[option]++;

        emit VoteEvent(msg.sender, option);
    }

    /*
     * @dev This function returns the winner of the election (UNTIL NOW)
     * Voting has no end date.
     */
    function getWinner()  public returns (bool, bool, bool) {
      if (_totalVotes[0]==_totalVotes[1]) {
        if (_totalVotes[0]==_totalVotes[2]) {
          emit DeclareWinnerEvent(true, true,  true);
          return (true,true, true);
        }
        else if (_totalVotes[0]>_totalVotes[2]) {
          emit DeclareWinnerEvent(true, true, false);
          return (true, true, false);
        }
        else {
          emit DeclareWinnerEvent(false, false, true);
          return (false,false,true);
        }
      }
      else if (_totalVotes[0]==_totalVotes[2]) {
        if (_totalVotes[0]>_totalVotes[1]) {
          emit DeclareWinnerEvent(true, false, true);
          return (true,false,true);
        }
        else {//_totalVotes[1] > _totalVotes[0] 
          emit DeclareWinnerEvent(false, true, false);
          return (false, true, false);
        }
      }  
      else if (_totalVotes[1]==_totalVotes[2]) {
        if (_totalVotes[0]>_totalVotes[1]) {
          emit DeclareWinnerEvent(true, false, false);
          return (true,false,false);
        }
        else { //_totalVotes[0]<_totalVotes[1]
          emit DeclareWinnerEvent(false, true, true);
          return (false,true,true);
        }
      }
      else if (_totalVotes[0]>_totalVotes[1] && _totalVotes[0]>_totalVotes[2]) {
          emit DeclareWinnerEvent(true, false, false);
          return (true,false,false);
      }
      else if (_totalVotes[1]>_totalVotes[0] && _totalVotes[1]>_totalVotes[2]) {
          emit DeclareWinnerEvent(false, true, false);
          return (false,true,false);
      }
      else if (_totalVotes[2]>_totalVotes[0] && _totalVotes[2]>_totalVotes[1]) {
          emit DeclareWinnerEvent(false, false, true);
          return (false,false,true);
      }

    }



 /**
	* @dev If this contract receives funds, it will emit an event and transfer the money back.
  */
	function() payable external { 

        emit FundsReturnedEvent(msg.sender, msg.value);
     		msg.sender.transfer(msg.value);
	}


  /**
   * @dev Useful to enable a pause in the creation of new Tradeable Contracts. 
   * It can only be called by the owner.
   * @param b If true, it is not possible to create new Tradeable Contracts.
   */
	function setCircuitBreaker (bool b) public onlyOwner {
		_stopped = b;
	} 	


}