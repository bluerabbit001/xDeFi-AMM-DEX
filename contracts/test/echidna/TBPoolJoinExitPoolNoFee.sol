import "../../lib/XNum.sol";

pragma solidity 0.5.17;

//  This test is similar to TBPoolJoinExit but with no exit fee
contract TBPoolJoinExitNoFee {
    bool public echidna_no_bug_found = true;

    // joinPool models the BPool.joinPool behavior for one token
    function joinPool(
        uint256 poolAmountOut,
        uint256 poolTotal,
        uint256 _records_t_balance
    ) internal pure returns (uint256) {
        uint256 ratio = XNum.bdiv(poolAmountOut, poolTotal);
        require(ratio != 0, "ERR_MATH_APPROX");

        uint256 bal = _records_t_balance;
        uint256 tokenAmountIn = XNum.bmul(ratio, bal);

        return tokenAmountIn;
    }

    // exitPool models the BPool.exitPool behavior for one token where no fee is applied
    function exitPoolNoFee(
        uint256 poolAmountIn,
        uint256 poolTotal,
        uint256 _records_t_balance
    ) internal pure returns (uint256) {
        uint256 ratio = XNum.bdiv(poolAmountIn, poolTotal);
        require(ratio != 0, "ERR_MATH_APPROX");

        uint256 bal = _records_t_balance;
        uint256 tokenAmountOut = XNum.bmul(ratio, bal);

        return tokenAmountOut;
    }

    // This function model an attacker calling joinPool - exitPool and taking advantage of potential rounding
    // issues to generate free pool token
    function joinAndExitNoFeePool(
        uint256 poolAmountOut,
        uint256 poolAmountIn,
        uint256 poolTotal,
        uint256 _records_t_balance
    ) public {
        uint256 tokenAmountIn = joinPool(
            poolAmountOut,
            poolTotal,
            _records_t_balance
        );

        // We constraint poolTotal and _records_t_balance
        // To have "realistic" values
        require(poolTotal <= 100 ether);
        require(poolTotal >= 1 ether);
        require(_records_t_balance <= 10 ether);
        require(_records_t_balance >= 10**6);

        poolTotal = XNum.badd(poolTotal, poolAmountOut);
        _records_t_balance = XNum.badd(_records_t_balance, tokenAmountIn);

        require(tokenAmountIn > 0); // prevent triggering the free token generation from joinPool

        require(poolTotal >= poolAmountIn);
        uint256 tokenAmountOut = exitPoolNoFee(
            poolAmountIn,
            poolTotal,
            _records_t_balance
        );
        require(_records_t_balance >= tokenAmountOut);

        // We try to generate free pool share
        require(poolAmountOut > poolAmountIn);
        require(tokenAmountOut == tokenAmountIn);
        echidna_no_bug_found = false;
    }
}
