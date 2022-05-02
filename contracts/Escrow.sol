// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Types.sol";

contract Escrow is Types {
  ////////////////////////////////////////
  //                                    //
  //         STATE VARIABLES            //
  //                                    //
  ////////////////////////////////////////

  /// @notice EOA of deployer wallet
  address public ochestrator;

  /// @notice address of accepted USDC on deployed chain
  address public usdcToken;

  ////////////////////////////////////////
  //                                    //
  //              FUNCTIONS             //
  //                                    //
  ////////////////////////////////////////
  modifier onlyOchesrator() {
    require(msg.sender == ochestrator, "F: only ochestrator");
    _;
  }

  constructor(address _ochestrator) {
    ochestrator = _ochestrator;
  }

  /**
   * @param _seller is the address of the vendor
   * @param _buyer is the address of the customer
   * @param _amount is the amount of USD to be transferred plus fees (18 decimals)
   * @param _rate is the rate to buy usdc against customer fiat
   * @param _fee is the amount of fees to be paid to the escrow to be minus from _amount (18 decimals)
   * @param _orderType is the type of order (0: buy, 1: sell)
   */
  function newOrder(
    address _seller,
    address _buyer,
    address _receiver,
    uint256 _amount,
    uint256 _rate,
    uint256 _fee,
    uint8 _orderType
  ) public returns (uint256) {
    require(msg.sender == _buyer, "C: customer only");
    require(_amount > 0, "C: invalid order");

    Order memory order = Order(
      _seller,
      _buyer,
      _receiver,
      _amount,
      _rate,
      _fee,
      _orderType,
      block.timestamp,
      0
    );

    orders.push(order);

    uint256 orderId = orders.length - 1;

    openOrders[_seller].push(orderId);

    emit OpenOrder(
      orderId,
      _seller,
      _buyer,
      _receiver,
      _amount,
      _rate,
      _fee,
      _orderType
    );

    return orderId;
  }

  function numberOfOpenOrders(address _seller) public view returns (uint256) {
    return openOrders[_seller].length;
  }

  function getOpenOrdersOf(address _seller)
    public
    view
    returns (uint256[] memory)
  {
    return openOrders[_seller];
  }

  function getOrderById(uint256 _orderId) public view returns (Order memory) {
    return orders[_orderId];
  }

  function closeOpenOrder(address _seller, uint256 _orderId) public {
    require(msg.sender == _seller, "C: only seller");
    delete openOrders[_seller][_orderId];

    Order storage order = orders[_orderId];

    order.fulfiledTime = block.timestamp;

    emit ClosedOrder(_orderId);
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
   * @dev allow deployer to withdraw all fees earned from escrow
   */
  function withdrawFeesEarned() public onlyOchesrator {
    uint256 totalFeeEarned = IERC20(usdcToken).balanceOf(address(this));

    IERC20(usdcToken).transfer(ochestrator, totalFeeEarned);
  }
}
