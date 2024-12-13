// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AtokToken is ERC20, ERC20Burnable, ERC20Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    mapping(address => bool) public blackListWallet;

    constructor() ERC20("Atok", "ATOK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MODERATOR_ROLE, msg.sender);
        _mint(msg.sender, 10000000000 * 10 ** 18);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function setBlackListWallet(address[] memory _address, bool result) public {
        require(hasRole(MODERATOR_ROLE, msg.sender), "not have permission");
        for (uint256 i = 0; i < _address.length; i++) {
            blackListWallet[_address[i]] = result;
        }
    }

    // The following functions are overrides required by Solidity.
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) whenNotPaused {
        require(!blackListWallet[from], "address from is blacklist");
        require(!blackListWallet[to], "address to is blacklist");
        super._update(from, to, value);
    }

    function clearUnknownToken(address _tokenAddress) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "not have permission");
        uint256 contractBalance = IERC20(_tokenAddress).balanceOf(
            address(this)
        );
        IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
    }
}
