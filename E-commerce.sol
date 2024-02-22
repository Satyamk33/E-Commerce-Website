// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ECommerce {
    address public owner;
    mapping(uint256 => Item) public Items;
    mapping(address => uint256) public Balance;
    uint256 mapsize;

    struct Item {
        string Name;
        uint256 Price;
        uint256 Quantity;
    }

    event ItemAdded(uint256 itemId, string itemName, uint256 price, uint256 quantity);
    event ItemPurchased(uint256 itemId, string itemName, uint256 quantity, uint256 totalPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function AddItem(uint256 itemId, string memory itemName, uint256 price, uint256 quantity) external onlyOwner {
        require(Items[itemId].Price == 0, "Item with this ID already exists");
        Items[itemId] = Item(itemName, price, quantity);
        emit ItemAdded(itemId, itemName, price, quantity);
        mapsize++;
    }

    function AvailableItems() external view returns (Item[] memory) {
        Item[] memory availableItems = new Item[](mapsize);
        uint256 index = 0;
        for (uint256 i = 0; i < mapsize; i++) {
            if (Items[i].Quantity > 0) {
                availableItems[index] = Items[i];
                index++;
            }
        }
        return availableItems;
    }

    function PurchaseItem(uint256 itemId, uint256 quantity) external payable {
        require(quantity > 0, "Quantity must be greater than zero");
        require(Items[itemId].Quantity >= quantity, "Not enough Quantity available");
        uint256 totalPrice = Items[itemId].Price * quantity;
        require(msg.value >= totalPrice, "Insufficient funds");

        Items[itemId].Quantity -= quantity;
        Balance[owner] += totalPrice;
        payable(owner).transfer(totalPrice);

        emit ItemPurchased(itemId, Items[itemId].Name, quantity, totalPrice);
    }

    function UserBalance() external view returns (uint256) {
        return Balance[msg.sender];
    }
}


contract Withdrawable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
