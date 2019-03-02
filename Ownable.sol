pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 *
 * This class was modified of OpenZeppelin to include multiple Owners
 */
contract Ownable {


    /**
     * @dev It contains the status of owners in this contract. All accounts that were included as owner is included in the mapping.
     * But, only the not removed ones, are linked with true.
     */
    mapping (address => bool) _bearer;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () public {
        _bearer[msg.sender] = true;
        emit OwnerAdded(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than owners.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is a owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return _bearer[msg.sender];
    }

    /**
     * @return true if account is a owner of the contract.
     */
    function isOwner(address account) public view returns (bool) {
        return _bearer[account];
    }

    /**
     * @return add a new owner to the set of owners of this contract
     */
     function addOwner(address account) public onlyOwner {
        require(account != address(0));
        require(!isOwner(account));

        _bearer[account] = true;
        emit OwnerAdded(account);

    }

    /**
     * @return remove the owner of the set of owners of this contract
     */
    function removeOwner(address account) public onlyOwner {
        require(account != address(0));
        require(isOwner(account));

        _bearer[account] = false;
        emit OwnerRemoved(account);

    }

}