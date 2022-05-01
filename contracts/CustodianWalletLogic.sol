// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Types.sol";
import "./Factory.sol";

contract CustodianWalletLogic is Types {
  /// @notice address of factory
  address public factory;

  function getTotalBalance() external view returns (uint256) {
    return _getUsdcBalance();
  }

  function getOpenOrders() external view returns (uint256[] memory) {
    return _getEscrow().getOpenOrdersOf(address(this));
  }

  function _getUsdcBalance() internal view returns (uint256) {
    return IERC20(_getEscrow().usdcToken()).balanceOf(msg.sender);
  }

  function _getEscrow() internal view returns (Escrow) {
    return Escrow(Factory(factory).escrowContractAddress());
  }

  /// @notice when a customer buy USD with local fiat
  function newBuyOrder(
    address _seller,
    uint256 _amount,
    uint256 _rate,
    uint256 _fee
  ) external returns (uint256) {
    return
      _getEscrow().newOrder(
        _seller, // vendor
        address(this),
        _amount,
        _rate,
        _fee,
        0 // buy
      );
  }

  /// @notice when a customer sell USD for local fiat to vendor
  function newSellOrder(
    address _buyer,
    uint256 _amount,
    uint256 _rate,
    uint256 _fee
  ) external returns (uint256) {
    return
      _getEscrow().newOrder(
        address(this),
        _buyer, //vendor
        _amount,
        _rate,
        _fee,
        1 // sell
      );
  }

  /// @notice returns operating balance of the seller custodian wallet (total USD balance - open orders against wallet)
  function availBalance() external view returns (uint256) {
    uint256[] memory openOrders = this.getOpenOrders();
    uint256 balance = this.getTotalBalance();

    for (uint256 queue = 0; queue < (openOrders.length - 1); queue++) {
      Order memory order = _getEscrow().getOrderId(openOrders[queue]);
      balance -= order.amount; // subtract amount of open order
    }

    return balance;
  }

  function sendFunds(address _to, uint256 _amount) external {
    require(_to != address(this), "CWL: self forbidden");
    require(_amount > 0, "CWL: amount cannot equal 0");
    require(_to != address(0x0), "CWL: invalid to address");
    require(this.availBalance() >= _amount, "CWL: insufficient funds");

    IERC20(_getEscrow().usdcToken()).transfer(_to, _amount);
  }
}
