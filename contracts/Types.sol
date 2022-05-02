// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Types {
  /// @notice structure of an order
  struct Order {
    address seller;
    address buyer;
    address receiver;
    uint256 amount;
    uint256 rate;
    uint256 fee;
    uint8 orderType;
    uint256 startTime;
    uint256 fulfiledTime;
  }

  Order[] public orders;

  mapping(address => uint256[]) public openOrders;

  /// @notice 0 = BUY, 1 = SELL
  enum OrderType {
    BUY,
    SELL
  }

  ////////////////////////////////////////
  //                                    //
  //              EVENTS                //
  //                                    //
  ////////////////////////////////////////

  event OpenOrder(
    uint256 orderId,
    address indexed seller,
    address indexed buyer,
    address indexed receiver,
    uint256 amount,
    uint256 rate,
    uint256 fee,
    uint8 orderType
  );

  event OrderFulfilled(uint256 orderId);

  event ClosedOrder(uint256 orderId);
}
