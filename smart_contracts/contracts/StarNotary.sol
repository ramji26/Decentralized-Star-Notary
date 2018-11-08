pragma solidity ^0.4.24;

import './ERC721Token.sol';

contract StarNotary is ERC721Token { 

    struct Star { 
        string name;
        string starStory;
        string dec;
        string mag;
        string ra;
    }
    
    mapping(uint256 => Star) public tokenIdToStarInfo;

    mapping(uint256 => uint256) public starsForSale;
    // due to limitation of Mappings, storing tokens(StarIds) as an array to facilitate iteration 
    uint256[] public starIds;

    function createStar(string _name, string _starStory, string _dec, string _mag, string _ra, uint256 _tokenId) public {
        _dec = strConcat("dec_",_dec);
        _mag = strConcat("mag_", _mag);
        _ra = strConcat("ra_", _ra);
        Star memory newStar = Star(_name, _starStory, _dec, _mag, _ra);

        require (!(checkIfStarExists(_newStar)), "Star already exists");

        tokenIdToStarInfo[_tokenId] = newStar;

        ERC721Token.mint(_tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0);

        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);

        require(msg.value >= starCost);

        clearPreviousStarState(_tokenId);

        transferFromHelper(starOwner, msg.sender, _tokenId);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }

        starOwner.transfer(starCost);
    }

    function clearPreviousStarState(uint256 _tokenId) private {
        //clear approvals 
        tokenToApproved[_tokenId] = address(0);

        //clear being on sale 
        starsForSale[_tokenId] = 0;
    }

    function checkIfStarExists(Star _newStar) private view returns(bool) {
        Star memory aStar;
        for (uint index = 0; index < starIds.length; index++) {
            aStar = tokenIdToStarInfo[starIds[index]];
            if (strCompare(aStar.dec, _newStar.ra) && strCompare(aStar.dec, _newStar.dec) && strCompare(aStar.dec, _newStar.mag)) {
                return true;
            }
        }
        return false;
    }

    function strCompare(string aString, string otherString) private pure returns(bool) {
        return keccak256(aString) == keccak256(otherString);
    }

    function strConcat(string _aString, _otherString) pure returns(string) {

        bytes memory _aByte = bytes(_aString);
        bytes memory _otherByte = bytes(_otherString);

        //string memory _finalString = new string(_aByte.length, _otherByte.length);
        bytes memory _workingByte = bytes(_finalString);
        uint index = 0;
        for (index; index < _aByte.length; index++) {
            _workingByte[index] = _aByte[index];
        }

        for (uint i = 0; i < _otherByte.length; i++) {
            _workingByte[index] = _otherByte[index];
        }

        return string(_workingByte);

    }


}