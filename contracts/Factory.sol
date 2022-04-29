// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CustodianWalletLogic.sol";
import "./CustodianWalletProxy.sol";

/**
 * @dev Factotory responsible for deploying Escrow, Custodian Wallet Logic and
 * managed CustodianWalletProxy for both Vendor and Customer.
 *
 * Note Controlled by deployer account.
 */
contract Factory {
  ////////////////////////////////////////
  //                                    //
  //         STATE VARIABLES            //
  //                                    //
  ////////////////////////////////////////

  /// @notice EOA of deployer wallet
  address public ochestrator;

  /// @notice the address of the Custodian Wallet Logic
  address public custodianWallet;

  /// @notice mapping of account unique id to custodian wallet
  /// Note avoid passing predictable number such as incremental number. Use UUID string instead
  mapping(string => address) public accounts;

  /// @notice address of accepted USDC on deployed chain
  address public usdcToken;

  event NewCustodian(string uniqueId, address indexed account);

  ////////////////////////////////////////
  //                                    //
  //              FUNCTIONS             //
  //                                    //
  ////////////////////////////////////////
  modifier onlyOchesrator() {
    require(msg.sender == ochestrator, "F: only ochestrator");
    _;
  }

  constructor() {
    ochestrator = msg.sender;
    custodianWallet = address(new CustodianWalletLogic());
  }

  /**
   * @dev allow deployer to update of USD Token contract address
   * @param usdcContractAddress is the address of the chosen stabel currency to accepted
   * Note use with caution, once a certain USD token is accepted changing will make the other USD token stuck
   */
  function setUsdcTokenAddress(address usdcContractAddress)
    public
    onlyOchesrator
  {
    require(usdcContractAddress != address(0x0), "F: invalid address");
    usdcToken = usdcContractAddress;
  }

  /**
   * @dev create a new custodian wallet
   * @param uuid is the unique id of the custodian wallet
   */
  function newCustodian(string memory uuid)
    public
    onlyOchesrator
    returns (string memory, address)
  {
    require(accounts[uuid] == address(0x0), "F: account exist");

    address wallet = address(
      new CustodianWalletProxy(custodianWallet, ochestrator, address(this))
    );
    accounts[uuid] = wallet;

    emit NewCustodian(uuid, wallet);

    return (uuid, wallet);
  }
}
