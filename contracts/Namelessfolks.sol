// SPDX-License-Identifier: MIT
/*
███╗░░██╗░█████╗░███╗░░░███╗███████╗██╗░░░░░███████╗░██████╗░██████╗  ███████╗░█████╗░██╗░░░░░██╗░░██╗░██████╗
████╗░██║██╔══██╗████╗░████║██╔════╝██║░░░░░██╔════╝██╔════╝██╔════╝  ██╔════╝██╔══██╗██║░░░░░██║░██╔╝██╔════╝
██╔██╗██║███████║██╔████╔██║█████╗░░██║░░░░░█████╗░░╚█████╗░╚█████╗░  █████╗░░██║░░██║██║░░░░░█████═╝░╚█████╗░
██║╚████║██╔══██║██║╚██╔╝██║██╔══╝░░██║░░░░░██╔══╝░░░╚═══██╗░╚═══██╗  ██╔══╝░░██║░░██║██║░░░░░██╔═██╗░░╚═══██╗
██║░╚███║██║░░██║██║░╚═╝░██║███████╗███████╗███████╗██████╔╝██████╔╝  ██║░░░░░╚█████╔╝███████╗██║░╚██╗██████╔╝
╚═╝░░╚══╝╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚══════╝╚══════╝╚═════╝░╚═════╝░  ╚═╝░░░░░░╚════╝░╚══════╝╚═╝░░╚═╝╚═════╝░
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Contract for NamelessFolks
/// @author AL GORITHM
contract Namelessfolks is ERC721Enumerable, Ownable {

  using SafeMath for uint256;

  uint256 public constant FOLK_GIVEAWAY = 300;
  uint256 public constant FOLK_PRIVATE = 2;
  uint256 public constant FOLK_PUBLIC = 11698;
  uint256 public constant FOLK_MAX = FOLK_GIVEAWAY + FOLK_PRIVATE + FOLK_PUBLIC;
  uint256 FOLK_PRICE = 0.02 ether;

  bool private _isOnPresale = true;
  bool private _isOnPublicSale = false;
  uint256 private giveAwayMinted;
  uint256 private publicMinted;
  uint256 private privateMinted;
  string private _baseTokenURI;

  address a1 = 0x;  // UPDATE BEFORE GO LIVE
  address a2 = 0x;  // UPDATE BEFORE GO LIVE

  mapping(uint256 => address) public folkToOwner;

  event FolkAdopted(uint256 id, uint256 price, address owner);

  constructor(string memory baseURI) ERC721("Namelessfolks", "FOLK") {
      setBaseURI(baseURI);
  }

  function preSaleMint() external payable {
    require(_isOnPresale, "TRANSACTION:  Presale is no longer active");
    require(!_isOnPublicSale, "TRANSACTION:  Public sale is active");
    require(FOLK_MAX > totalSupply(), "SUPPLY:  Nameless Folks Token cap reached");
    require(msg.value >= FOLK_PRICE, "PAYMENT: invalid ETH value");
    require(publicMinted <= FOLK_PUBLIC, "SUPPLY:  Nameless Folks Sold Out");

    publicMinted++;
    uint256 supply = totalSupply()+1;
    _safeMint(msg.sender, supply);

    folkToOwner[supply] = msg.sender;
  }

  function giveAwayMint(address[] calldata receivers) external onlyOwner {
      require(totalSupply() + receivers.length <= FOLK_MAX, "SUPPLY:  Nameless Folks Token cap reached");
      require(giveAwayMinted + receivers.length <= FOLK_GIVEAWAY, "SUPPLY:  Give away supply empty");

      for (uint256 i = 0; i < receivers.length; i++) {
          giveAwayMinted++;
          uint256 supply = totalSupply()+1;
          _safeMint(receivers[i], supply);
          folkToOwner[supply] = msg.sender;
      }
  }

  function publicSaleMint() external payable {
    require(!_isOnPresale, "TRANSACTION:  Presale is active");
    require(_isOnPublicSale, "TRANSACTION:  Public sale is not active");
    require(FOLK_MAX > totalSupply(), "SUPPLY:  Nameless Folks Token cap reached");
    require(msg.value >= FOLK_PRICE, "PAYMENT: invalid ETH value");
    require(publicMinted <= FOLK_PUBLIC, "SUPPLY:  Nameless Folks Sold Out");

    publicMinted++;
    uint256 supply = totalSupply()+1;
    _safeMint(msg.sender, supply);

    folkToOwner[supply] = msg.sender;
  }

  function privateMint(address _to, uint256 _tokenId) public onlyOwner returns (uint256) {
    require(!_isOnPresale, "TRANSACTION:  Presale is active");
    require(!_isOnPublicSale, "TRANSACTION:  Public sale is active");
    require(FOLK_MAX > totalSupply(), "SUPPLY:  Nameless Folks Token cap reached");
    require(privateMinted <= FOLK_PRIVATE, "SUPPLY:  Nameless Folks Sold Out");

    privateMinted++;
    totalSupply() + 1;
    _safeMint(_to, _tokenId);

    folkToOwner[_tokenId] = _to;
    return _tokenId;
  }

  function adoptFolk(uint256 _tokenId) external payable {
      require(_exists(_tokenId), "SUPPLY:  Nonexistent token");
      require(msg.value >= FOLK_PRICE, "PAYMENT:  Minimum price to send is 0.02 ether");
      require(FOLK_MAX > totalSupply(), "SUPPLY:  Nameless Folks Token cap reached");
      address _owner = folkToOwner[_tokenId];
      address payable _ownerpayable = payable(folkToOwner[_tokenId]);
      require(_owner != msg.sender, "TRANSACTION:  Buyer is the same as the seller");
      _ownerpayable.transfer(msg.value);

      emit FolkAdopted(_tokenId, msg.value, msg.sender);
  }

  function _transferFolk(address _from, address _to, uint256 _tokenId) private {
    safeTransferFrom(_from, _to, _tokenId);
    folkToOwner[_tokenId] = _to;
  }

  function transferFolkFrom(address _from, address _to, uint256 _tokenId) external {
    require(msg.sender == folkToOwner[_tokenId]);
    _transferFolk(_from, _to, _tokenId);
  }

  function getFolksByOwner(address _owner) external view returns (uint256[] memory) {
    uint256 owned = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](owned);
    for(uint256 i = 0; i < owned; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function numberOfFolksOwned(address _owner) external view returns (uint256) {
    return balanceOf(_owner);
  }

  function folkOwner(uint256 _tokenId) external view returns (address) {
    return folkToOwner[_tokenId];
  }

  function setFOLKPrice(uint256 _price) external onlyOwner {
    FOLK_PRICE = _price;
  }

  function getFOLKPrice() external view returns (uint256) {
    return FOLK_PRICE;
  }

  function isOnPreSale() external view returns (bool) {
    return _isOnPresale;
  }

  function switchPresale(bool val) public onlyOwner {
      _isOnPresale = val;
  }

  function isOnPublicSale() external view returns (bool) {
    return _isOnPublicSale;
  }

  function switchPublicSale(bool val) public onlyOwner {
      _isOnPublicSale = val;
  }

  function totalGiveAwayMinted() external view returns (uint256) {
    return giveAwayMinted;
  }

  function totalPublicMinted() external view returns (uint256) {
    return publicMinted;
  }

  function totalPrivateMinted() external view returns (uint256) {
    return privateMinted;
  }

  function setMembersAddresses(address[] memory _a) public onlyOwner {
      a1 = _a[0];
      a2 = _a[1];
  }

  function getMembersAddresses() public onlyOwner view returns (address[] memory) {
      address[] memory ownerAddresses = new address[](2);
      ownerAddresses[0] = a1;
      ownerAddresses[1] = a2;
      return ownerAddresses;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
      require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
      string memory baseURI = _baseURI();
      return string(abi.encodePacked(baseURI, Strings.toString(tokenId)));
  }

  function _baseURI() internal view virtual override returns (string memory) {
      return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) public onlyOwner {
      _baseTokenURI = baseURI;
  }

  function withdrawTeam(uint256 amount) public payable onlyOwner {
      uint256 _each = amount / 2;
      require(payable(a1).send(_each));
      require(payable(a2).send(_each));
  }

}
