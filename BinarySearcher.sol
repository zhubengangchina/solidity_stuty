// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/*
二分查找 (Binary Search)
题目描述：在一个有序数组中查找目标值。
输入：

一个升序数组 arr（类型 uint[] memory）

一个目标值 target（uint）

输出：

若存在，返回目标值的索引（uint 类型）

若不存在，返回 -1，我们用 int 类型表示返回值
*/
contract BinarySearcher {

    function binarySearch(uint[] memory arr,uint target) public pure returns (int) {
        int left = 0;
        int right = int(arr.length) - 1;

        while (left <= right) {
            int mid = left + (right - left) / 2;
            uint midVal = arr[uint(mid)];
            if (midVal == target) {
                return int(mid);
            } else if (midVal < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }        
        }
    
        return -1; // not found
    }



}