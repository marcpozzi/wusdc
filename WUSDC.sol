// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
}

contract WUSDC {

    // This is NOT Wrapped USDC, its my token and I've decided to offer it
    // at the price of 1 USDC token.
    // SIDENOTE: This token cannot be blacklisted

    string public name     = "WUSDC";
    string public symbol   = "WUSDC";
    uint8  public decimals = 6;
    uint256 public totalSupply;

    bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    // --- Math ---
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }

    function usdcAddress() internal view returns (address _address) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            _address := sload(slot)
        }
    }

    function deposit(uint wad) public {
        address _usdcAddress = usdcAddress();
        IERC20(_usdcAddress).transferFrom(_usdcAddress, address(this), wad);
        balanceOf[msg.sender] += wad;
        totalSupply = add(totalSupply, wad);
        emit Deposit(msg.sender, wad);
    }

    // No withdraw implemented, WUSDC forever

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}
