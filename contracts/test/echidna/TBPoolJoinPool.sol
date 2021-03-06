import "../../lib/XNum.sol";

pragma solidity 0.5.17;

contract TBPoolJoinPool {
    bool public echidna_no_bug_found = true;

    // joinPool models the BPool.joinPool behavior for one token
    // A bug is found if poolAmountOut is greater than 0
    // And tokenAmountIn is 0
    function joinPool(
        uint256 poolAmountOut,
        uint256 poolTotal,
        uint256 _records_t_balance
    ) public returns (uint256) {
        // We constraint poolTotal and _records_t_balance
        // To have "realistic" values
        require(poolTotal <= 100 ether);
        require(poolTotal >= 1 ether);
        require(_records_t_balance <= 10 ether);
        require(_records_t_balance >= 10**6);

        uint256 ratio = XNum.bdiv(poolAmountOut, poolTotal);
        require(ratio != 0, "ERR_MATH_APPROX");

        uint256 bal = _records_t_balance;
        uint256 tokenAmountIn = XNum.bmul(ratio, bal);

        require(poolAmountOut > 0);
        require(tokenAmountIn == 0);

        echidna_no_bug_found = false;
    }
}
