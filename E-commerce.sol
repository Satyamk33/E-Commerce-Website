// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ECommerce {
    address public owner;
    mapping(uint256 => Item) public items;
    mapping(address => uint256) public balances;
    uint256 mapsize;

    struct Item {
        string name;
        uint256 price;
        uint256 quantity;
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

    function addItem(uint256 itemId, string memory itemName, uint256 price, uint256 quantity) external onlyOwner {
        require(items[itemId].price == 0, "Item with this ID already exists");
        items[itemId] = Item(itemName, price, quantity);
        emit ItemAdded(itemId, itemName, price, quantity);
        mapsize++;
    }

    function getAvailableItems() external view returns (Item[] memory) {
        Item[] memory availableItems = new Item[](mapsize);
        uint256 index = 0;
        for (uint256 i = 0; i < mapsize; i++) {
            if (items[i].quantity > 0) {
                availableItems[index] = items[i];
                index++;
            }
        }
        return availableItems;
    }

    function purchaseItem(uint256 itemId, uint256 quantity) external payable {
        require(quantity > 0, "Quantity must be greater than zero");
        require(items[itemId].quantity >= quantity, "Not enough quantity available");
        uint256 totalPrice = items[itemId].price * quantity;
        require(msg.value >= totalPrice, "Insufficient funds");

        items[itemId].quantity -= quantity;
        balances[owner] += totalPrice;
        payable(owner).transfer(totalPrice);

        emit ItemPurchased(itemId, items[itemId].name, quantity, totalPrice);
    }

    function getUserBalance() external view returns (uint256) {
        return balances[msg.sender];
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
