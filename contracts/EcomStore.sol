pragma solidity ^0.5.0;

/**
@title Ecommerce Store
@dev   A simple listing and buying smart contract
 */
contract EcomStore {

    //owner of the contract
    address payable admin;

    //check the contract or admin is active
    bool    isAdminOnline;

    //data structure for product information
    struct Product {
        uint productId;
        address seller;
        address buyer;
        string productName;
        string productDesc;
        uint productPrice;
        bool isSold;
        bool isShipped;
        bool isReceived;
    }

    //array of Product struct
    Product[] public products;
    
    event ListProductEvent(address seller, string name, uint price);

    constructor () public {
        admin = msg.sender;
        isAdminOnline = true;
    }

    /**
        @dev add saleable product
    */
    function listProduct(string memory _productName, string memory _productDesc, uint _productPrice) public returns (uint) {
        require(isAdminOnline == true,"Contract is not online");
        require(_productPrice > 0,"Price is not valid");
        
        uint count = products.length;
        products.push(
            Product({
                productId: count + 1,
                seller: msg.sender,
                buyer: address(0),
                productName: _productName,
                productDesc: _productDesc,
                productPrice: _productPrice,
                isSold: false,
                isShipped: false,
                isReceived: false  
            })    
        );
        assert(count + 1 == products.length);
        emit ListProductEvent(msg.sender, _productName, _productPrice);

        return products.length;
    }

    /**
        @dev get specific product
        @param _productId is the id of the product in Array
    */
    function getProduct(uint _productId) public view returns (uint productId,
        string memory productName,
        string memory productDesc,
        uint productPrice,
        bool isSold,
        bool isShipped,
        bool isReceived) {

        return (
            products[_productId].productId,
            products[_productId].productName,
            products[_productId].productDesc,
            products[_productId].productPrice,
            products[_productId].isSold,
            products[_productId].isShipped,
            products[_productId].isReceived
        );

    }

    /**
        @dev check if product is shipped.
    */
    function productShipped(uint _productId) public returns(bool) {
        require(products[_productId].isSold == true,"Cannot ship unsold product");
        require(products[_productId].seller == msg.sender,"Only seller can receive amount");
        return products[_productId].isShipped = true;
    }

    /**
        @dev check if product already received by the buyer. Only buyer can mark call
    */
    function productReceived(uint _productId) public returns(bool) {
        require(products[_productId].buyer == msg.sender, "Only buyer can receive the product");
        return products[_productId].isReceived = true;
    }

    /**
        @dev check if product was sold
    */
    function productSold(uint _productId) public  returns(bool)  {
        return products[_productId].isSold = true;
    }

    /**
        @dev request the money after product was shipped and marked as received by the buyer
    */
    function fundTransfer(uint _productId) public {
        require(isAdminOnline == true,"Contract is not online");
        require(products[_productId].seller == msg.sender,"Only seller can receive amount");
        require(products[_productId].isReceived == true, "Product still not receive");
        
        msg.sender.transfer(products[_productId].productPrice);
    }

    function buyProduct(uint _productId) public payable {
        require(isAdminOnline == true,"Contract is not online");
        require(products[_productId].productPrice == msg.value, "Insufficient amount to buy this product");
      
        products[_productId].buyer = msg.sender;
        products[_productId].isSold = true;
    }

    function kill() public {
        require(msg.sender == admin,"Only adminstrator can kill the contract");
        selfdestruct(admin);
    }
}