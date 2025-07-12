// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//整数转罗马数字

contract RomanConverter {
    uint[] private values = [1000, 900, 500, 400, 100, 90,
        50, 40, 10, 9, 5, 4, 1];

    string[] private symbols = ["M", "CM", "D", "CD", "C", "XC",
        "L", "XL", "X", "IX", "V", "IV", "I"];

    function toRoman(uint num) public view returns(string memory) {
        require(num > 0 && num < 3999,"out of range");
        bytes memory result;
        for (uint i = 0;i < values.length && num > 0 ;i++){
            while (num >= values[i]) {
                result = bytes.concat(result,bytes(symbols[i]));
                num -= values[i];
            }
        }
        return string(result);
    }

}