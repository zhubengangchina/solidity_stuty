# Solidity学习指南

## 学习路线
1. **基础入门**：语言语法、数据类型、函数、修饰符等
2. **核心特性**：合约生命周期、继承、事件、错误处理、modifier、安全性等
3. **高级特性**：抽象合约、接口、库、fallback、assembly
4. **以太坊交互**：合约部署、调用、gas、ether传输、msg、tx、合约间调用
5. **实战开发**：NFT、ERC20、拍卖、DAO、DeFi示例，从0到部署上线

## 一、基础语法

### 1. 常见数据类型

| 类型          | 说明                             | 示例                                 |
| ------------- | -------------------------------- | ------------------------------------ |
| `uint`, `int` | 无符号/有符号整数（默认256位）   | `uint age = 18;`                     |
| `bool`        | 布尔值                           | `bool isReady = true;`               |
| `address`     | 以太坊地址                       | `address owner;`                     |
| `string`      | 字符串                           | `string name = "Alice";`             |
| `bytes`       | 定长或变长字节数组               | `bytes32 hash;`                      |
| `array`       | 数组                             | `uint[] numbers;`                    |
| `mapping`     | 映射                             | `mapping(address => uint) balances;` |

### 2. 变量声明与可见性

```solidity
string public name;      // 有public自动生成getter
uint private balance;    // 仅合约内部访问
bool internal isActive;  // 仅当前合约或继承合约访问
address externalAccount; // external通常用于函数
```

| 修饰符     | 含义                               |
| ---------- | ---------------------------------- |
| `public`   | 对外可见（默认生成getter）         |
| `private`  | 仅当前合约内部可访问               |
| `internal` | 当前合约 + 子合约可访问              |
| `external` | 通常用于函数，表示只能合约外部调用 |

### 3. 函数基本语法

```solidity
function add(uint a, uint b) public pure returns (uint) {
    return a + b;
}
```

| 修饰符    | 含义                   |
| --------- | ---------------------- |
| `view`    | 只读，不修改状态       |
| `pure`    | 纯函数，不访问合约状态 |
| `payable` | 允许接收以太币         |
| `returns` | 函数返回值声明         |

#### `view`函数详解

**定义**：`view`函数是只读函数，可以读取合约中的状态变量，但不能对状态变量进行修改。

**不能做的事情**：
- 修改状态变量
- 写入storage
- 发起转账、调用其他合约修改状态
- 发出事件（event）

**可以做的事情**：
- 读取状态变量
- 做计算或判断

```solidity
uint public count = 10;

function getCount() public view returns (uint) {
    return count; // ✅ 读取状态变量，合法
}
```

#### `pure`函数详解

**定义**：`pure`函数是完全纯净的函数，不能访问合约中的任何状态变量或区块链环境变量，只依赖输入和输出。

**不能做的事情**：
- 读取或修改状态变量
- 访问`msg.sender`、`block.timestamp`等区块链上下文
- 发出事件、调用其他合约

**可以做的事情**：
- 进行纯粹计算（数学函数等）

```solidity
function add(uint a, uint b) public pure returns (uint) {
    return a + b;  // ✅ 不依赖合约状态，只做数学计算
}
```

### 4. memory vs storage

Solidity中引用类型（string, array, struct, mapping等）默认存储在合约`storage`中，但函数参数默认用`memory`临时保存。

```solidity
function setName(string memory newName) public {
    name = newName;
}
```

| 关键字     | 说明                                 |
| ---------- | ------------------------------------ |
| `memory`   | 临时存储，函数调用完销毁             |
| `storage`  | 持久存储在区块链上                   |
| `calldata` | 函数外部调用参数只读区域（gas最省）  |

## 二、数据结构

### 1. Struct（结构体）

结构体可以用来自定义复杂的数据类型，比如「用户信息」「订单」「NFT详情」。

```solidity
struct User {
    string name;
    uint age;
    bool isActive;
}

User public user;
```

使用：
```solidity
function setUser(string memory _name, uint _age) public {
    user = User(_name, _age, true);
}
```

### 2. Array（数组）

Solidity支持动态数组和固定数组。

```solidity
function addNumber(uint num) public {
    numbers.push(num);
}
```

- `push()`添加元素
- `numbers.length`获取长度
- `numbers[i]`获取第i个元素

### 3. Mapping（映射）

映射是Solidity中最常用的结构之一，适合做键值存储，比如余额表、用户信息表等。

```solidity
mapping(address => uint) public balances;
```

- `balances[msg.sender] = 100;`写入
- `balances[msg.sender];`读取
- 注意：**mapping无法遍历，也不能直接获取keys**

### 4. Event（事件）

事件用于在链上向链下（前端）**广播消息**，比如交易记录、状态变化等。

```solidity
event UserCreated(string name, uint age);
```

使用`emit`触发事件：
```solidity
emit UserCreated("Alice", 25);
```

前端监听事件可以用Web3.js或Ethers.js实现用户交互。

#### `indexed`参数

当你在事件参数前加上`indexed`，代表该参数会被加入到**以太坊日志（logs）的topics中**，从而可以通过参数值**过滤查询**这个事件。

**每个事件最多支持3个`indexed`参数。**

```solidity
event UserRegistered(address indexed user, string name);
```

这表示：
- `user`这个地址是indexed——**可以作为查询过滤条件**
- `name`是普通参数，只能在事件内容里看到，**不能直接用来搜索**

### 实战合约练习：用户注册表

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UserRegistry {
    struct User {
        string name;
        uint age;
        bool isActive;
    }

    mapping(address => User) public users;
    address[] public userList;

    event UserRegistered(address indexed user, string name);

    function register(string memory _name, uint _age) public {
        require(_age > 0, "Age must be positive");
        users[msg.sender] = User(_name, _age, true);
        userList.push(msg.sender);
        emit UserRegistered(msg.sender, _name);
    }

    function getMyInfo() public view returns (string memory, uint, bool) {
        User memory u = users[msg.sender];
        return (u.name, u.age, u.isActive);
    }

    function getUserCount() public view returns (uint) {
        return userList.length;
    }
}
```

## 三、控制结构与错误处理

### 1. 条件与控制语句

**if/else**：
```solidity
function checkAge(uint age) public pure returns (string memory) {
    if (age >= 18) {
        return "Adult";
    } else {
        return "Minor";
    }
}
```

**for、while**：
```solidity
function sumToN(uint n) public pure returns (uint sum) {
    for (uint i = 1; i <= n; i++) {
        sum += i;
    }
}
```

### 2. 错误处理

#### `require(condition, "错误信息")`
- 最常用
- 判断条件不符合就终止执行，**会退回状态，返还gas**

```solidity
function setAge(uint age) public {
    require(age > 0, "Age must be positive");
    // age合法才会执行到这里
}
```

#### `revert("错误信息")`
- 主动中断执行（适合多条件判断中失败分支）

```solidity
function testRevert(uint x) public pure {
    if (x < 10) {
        revert("x must >= 10");
    }
}
```

#### `assert(condition)`
- 通常只用于**检查不变量（invariant）**，不是业务逻辑判断
- 条件失败会**消耗全部gas**

```solidity
function alwaysTrue() public pure {
    assert(1 == 1); // 如果失败，说明代码有严重逻辑错误
}
```

> 推荐顺序：**require > revert > assert（慎用）**

### 3. `modifier`（函数修饰器）

`modifier`是Solidity中实现访问控制、安全性、抽象逻辑复用的强大工具。

```solidity
address public owner;

modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _; // 代表"继续执行原函数体"
}
```

应用方式：
```solidity
function withdraw() public onlyOwner {
    // 只有合约创建者可以执行
}
```

### 实战练习合约：拥有者控制 + 安全转账

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SafeWallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    receive() external payable {} // 允许接收ETH

    function withdraw(uint amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
```

## 四、合约继承

Solidity支持类似面向对象语言的继承机制，子合约可以继承父合约的状态变量、函数、事件等。

### 1. 基础语法

```solidity
contract Parent {
    function sayHello() public pure returns (string memory) {
        return "Hello from Parent";
    }
}

contract Child is Parent {
    // 继承了sayHello()
}
```

### 2. 函数重写（override）

当子合约想自定义继承来的函数逻辑时，可以使用`override`：

```solidity
contract Parent {
    function greet() public pure virtual returns (string memory) {
        return "Hello from Parent";
    }
}

contract Child is Parent {
    function greet() public pure override returns (string memory) {
        return "Hello from Child";
    }
}
```

> `virtual`表示函数可以被重写，`override`表示函数正在重写父类方法。

### 3. 构造函数继承

父合约带有构造函数时，子合约必须通过constructor显式调用它。

```solidity
contract Parent {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract Child is Parent {
    constructor(string memory _childName) Parent(_childName) {
        // 子合约通过调用父构造函数初始化name
    }
}
```

### 4. 调用父类方法（super）

```solidity
contract Parent {
    function greet() public pure virtual returns (string memory) {
        return "Parent";
    }
}

contract Child is Parent {
    function greet() public pure override returns (string memory) {
        return string(abi.encodePacked("Child + ", super.greet()));
    }
}
```

### 实战练习合约：动物叫声

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Animal {
    string public species;

    constructor(string memory _species) {
        species = _species;
    }

    function speak() public pure virtual returns (string memory) {
        return "Some animal sound";
    }
}

contract Dog is Animal {
    constructor() Animal("Dog") {}

    function speak() public pure override returns (string memory) {
        return "Woof!";
    }
}
```

### 继承功能总结

| 功能           | 关键字        |
| -------------- | ------------- |
| 允许子类重写   | `virtual`     |
| 重写父类方法   | `override`    |
| 调用父类函数   | `super`       |
| 调用父构造函数 | `Parent(...)` |

## 五、Solidity高级特性

### 1. 抽象合约（Abstract Contract）

**定义**：抽象合约是包含未实现函数的合约，不能被直接部署，必须被子类实现。

```solidity
abstract contract Animal {
    function speak() public view virtual returns (string memory);
}

contract Dog is Animal {
    function speak() public pure override returns (string memory) {
        return "Woof";
    }
}
```

**关键点**：
- 抽象合约中的未实现函数用`virtual`修饰，不需要函数体
- 抽象合约自己不能部署，子合约必须`override`并实现所有函数

### 2. 接口（Interface）

**定义**：接口是一种"纯声明"的合约结构，只能包含函数签名，通常用于调用外部合约或定义标准协议。

```solidity
interface ICounter {
    function increment() external;
    function getCount() external view returns (uint);
}
```

你可以用这个接口去与已部署的Counter合约交互：

```solidity
contract UseCounter {
    function callCounter(address counterAddr) public {
        ICounter(counterAddr).increment();
    }
}
```

**接口规则**：
- 所有函数必须是`external`
- 不允许定义变量、构造函数
- 默认都是`virtual` + `override`

#### 接口使用示例

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVoting {
    function vote(string calldata nam) external; 
    function getVotes(string calldata name) external view returns (uint); 
}

contract VotingController {
    function voteViaInterface(address votingAddr, string calldata name) public {
        IVoting(votingAddr).vote(name);
    }

    function queryVotes(address votingAddr, string calldata name) public view returns (uint) {
        return IVoting(votingAddr).getVotes(name);
    }
}
```

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    address public owner;
    mapping(string => uint) private votes;
    string[] private candidates;

    constructor() {
        owner = msg.sender;
    } 

    modifier onlyOwner {
        require(msg.sender == owner, "only owner");
        _;
    }

    // 给某个候选人投票（如果是第一次投票，该候选人会被记录）
    function vote(string calldata name) public {
        if (votes[name] == 0) {
            candidates.push(name);
        }
        votes[name] += 1;
    }

    // 获取某个候选人的得票数
    function getVotes(string memory name) public view returns (uint) {
        return votes[name];
    }

    // 重置所有候选人的得票数（仅限owner）
    function resetVotes() public onlyOwner {
        for (uint i = 0; i < candidates.length; i++) {
            votes[candidates[i]] = 0;
        }
    }
}
```

#### Interface vs Abstract合约的区别总结

| 特性               | 接口Interface                      | 抽象合约Abstract     |
| ------------------ | ---------------------------------- | -------------------- |
| 是否可声明变量     | ❌ 不可                             | ✅ 可以               |
| 是否可声明实现函数 | ❌ 不可                             | ✅ 可以               |
| 函数类型限制       | 只能`external`                     | 任意public/view/pure |
| 使用场景           | 调用外部合约、标准定义（如IERC20） | 逻辑框架、继承模板   |

> 接口中的函数签名必须与被调用合约中的函数**名称、参数类型、顺序**一致，否则调用失败。

### 3. ABI（Application Binary Interface）

**定义**：ABI是智能合约与外界交互时，函数调用与数据编码的标准协议。

它描述了：
- 函数名+参数类型（用于生成selector）
- 参数和返回值的编码格式（用于call、解码）

**调用原理流程**：
```
调用合约vote("Alice")
↓
编译器：根据ABI生成selector + 编码参数
↓
打包成calldata
↓
EVM解析calldata，执行目标函数
```

**示例（函数编码）**：

函数签名：
```solidity
function vote(string calldata name)
```

selector：
```solidity
bytes4(keccak256("vote(string)")) = 0x2f265cf6
```

ABI编码结果：
```
0x2f265cf6 + encoded("Alice")
```

### 4. Library（库）

**定义**：`library`是Solidity提供的一种特殊合约结构，专门用来复用函数逻辑，而不是存储数据或部署状态。

类似Java中的工具类（`MathUtils`、`StringUtils`等），或者JavaScript中的`lodash`工具包。

**主要特点**：

| 特点                                            | 说明                                        |
| ----------------------------------------------- | ------------------------------------------- |
| 无状态变量                                      | 不能有`storage`状态变量（也不能接收ETH）    |
| 不能继承/被继承                                 | 与合约不同                                  |
| 所有函数默认`internal`（可internal/external）   |                                             |
| 可以通过`.using for`扩展类型                    |                                             |
| 可节省Gas                                       | 尤其用于结构体、复杂运算处理时              |

**使用方式**：

1. 纯粹作为工具函数调用
```solidity
library MathLib {
    function square(uint x) internal pure returns (uint) {
        return x * x;
    }
}

contract Calculator {
    function getSquare(uint n) public pure returns (uint) {
        return MathLib.square(n);
    }
}
```

2. 使用`using for`给类型扩展方法
```solidity
library ArrayLib {
    function sum(uint[] memory arr) internal pure returns (uint total) {
        for (uint i = 0; i < arr.length; i++) {
            total += arr[i];
        }
    }
}

contract TestArray {
    using ArrayLib for uint[];

    function getSum() public pure returns (uint) {
        uint[] memory data = new uint[](3);
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;
        return data.sum(); // 像调用方法一样
    }
}
```

**场景应用**：

| 应用场景   | 示例                                         |
| ---------- | -------------------------------------------- |
| 数学工具   | 比如`SafeMath`, `sqrt`, `avg`等              |
| 结构体操作 | `mapping`/`struct`增删查封装                 |
| 字符串处理 | 拼接、比较、转换（用`StringUtils`）          |
| 标准库封装 | ERC20使用的`SafeERC20`、`Address`等都是库    |

**示例库合约**：
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title MyMath - 自定义数学库
library MyMath {
    /// @notice 返回输入的2倍
    function double(uint x) internal pure returns (uint) {
        return x * 2;
    }

    /// @notice 返回a和b的平均值（向下取整）
    function avg(uint a, uint b) internal pure returns (uint) {
        return (a + b) / 2;
    }
}

/// @title 使用MyMath的合约
contract UseMath {
    function getDouble(uint x) public pure returns (uint) {
        return MyMath.double(x); // 调用库函数
    }

    function getAvg(uint a, uint b) public pure returns (uint) {
        return MyMath.avg(a, b); // 调用库函数
    }
}
```

## 六、Fallback与Receive函数

### 1. 概念速览

Solidity合约通过两种特殊函数处理「非正常调用」或「转账」行为：

| 特殊函数     | 用于处理                                                     |
| ------------ | ------------------------------------------------------------ |
| `receive()`  | 仅当收到ETH且calldata为空时触发（比如`address(this).transfer(...)`） |
| `fallback()` | 当调用不存在的函数、或者收到ETH且没有`receive()`时触发       |

**一句话总结**：
- `receive()` → **专门收钱**
- `fallback()` → **兜底逻辑**，用于处理未知函数调用或calldata不匹配的情况

### 2. 函数定义格式

**`receive()`示例**：
```solidity
receive() external payable {
    // 收ETH时执行
}
```
> 必须是`external payable`

**`fallback()`示例**：
```solidity
fallback() external payable {
    // 未知函数调用或calldata存在但未匹配函数
}
```
> 也必须是`external`，加`payable`才能收钱

### 3. 示例合约：接收ETH并记录日志

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FallbackExample {
    event Received(address sender, uint amount, string functionCalled);

    // 专门接收ETH
    receive() external payable {
        emit Received(msg.sender, msg.value, "receive");
    }

    // 当调用不存在的函数，或calldata不匹配时执行
    fallback() external payable {
        emit Received(msg.sender, msg.value, "fallback");
    }

    // 可用于查询余额
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
```

## 七、合约收款、转账与安全问题

### 1. 合约如何接收ETH

**合约能收钱的前提**：必须有`payable`修饰

| 方式                   | 是否能收钱？                                |
| ---------------------- | ------------------------------------------- |
| 普通函数，无`payable`  | ❌ 拒收ETH，直接revert                       |
| `payable`函数          | ✅ 可接受转账（含`receive()`/`fallback()`）  |

**推荐的标准做法**：
```solidity
event Received(address sender, uint amount, string functionCalled);

// 仅当calldata为空时触发（比如user直接转账）
receive() external payable {
    emit Received(msg.sender, msg.value, "receive");
}

// 当调用未知函数或calldata不为空但无匹配函数
fallback() external payable {
    emit Received(msg.sender, msg.value, "fallback");
}
```

> 如果不定义`receive()`或`fallback()`，转账会**revert**。

### 2. 合约如何转出ETH（转账）

**方法一**：`transfer()`
```solidity
payable(msg.sender).transfer(1 ether);
```
- 自动转2300 gas
- 若收款地址为合约，**不能执行复杂逻辑**
- 若失败→自动revert

**方法二**：`send()`（不推荐）
```solidity
bool success = payable(msg.sender).send(1 ether);
require(success, "Send failed");
```
- 同样2300 gas
- 不会自动revert，需手动判断返回值
- 容易被忽略安全风险

**方法三**：`call{value: x}`（✅ 推荐）
```solidity
(bool success, ) = payable(msg.sender).call{value: 1 ether}("");
require(success, "Call failed");
```
- ✅ 支持**自定义gas**
- ✅ 兼容性最好
- ✅ 被大多数官方库推荐（如`OpenZeppelin`）

**推荐转账方式对比**：

| 方法       | 自动回滚 | Gas限制       | 推荐程度         |
| ---------- | -------- | ------------- | ---------------- |
| `transfer` | ✅        | 固定2300 gas  | ⚠️ 可用但容易失败 |
| `send`     | ❌        | 固定2300 gas  | ❌ 不推荐         |
| `call`     | ✅        | 自定义gas     | ✅ 推荐 ✅         |

### 3. 合约收付款的安全注意事项

#### 重入攻击（Reentrancy）

**攻击流程**：
1. 合约A调用用户地址`call{value:...}`转账
2. 如果用户是合约地址，可以触发其`fallback()`
3. `fallback()`再次调用合约A的逻辑，**重复提款**

**解决方案**：
- **写入状态 > 转账 > 检查**
- 使用`ReentrancyGuard`（OpenZeppelin）

示例（✅ 安全）：
```solidity
mapping(address => uint) public balances;
bool internal locked;

function withdraw() external nonReentrant {
    uint amount = balances[msg.sender];
    balances[msg.sender] = 0; // ✅ 先更新状态
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Transfer failed");
}
```

#### 重入攻击流程详解
1. 合约A中有withdraw()函数
2. 用户A（攻击者）部署恶意合约Attacker
3. Attacker向合约A存入资金
4. Attacker调用A.withdraw()
5. A.transfer()向Attacker合约转账
6. Attacker的fallback()被触发因为Attacker没有receive函数
7. fallback中再次调用A.withdraw()
8. 又触发转账+fallback，直到A资金被榨干

**如何防止重入攻击？**

| 方案                            | 是否推荐   | 原因                |
| ------------------------------- | ---------- | ------------------- |
| ✅ 先更新状态再转账              | ✅ 强烈推荐 | 简洁+高效           |
| ✅ 使用`ReentrancyGuard`        | ✅ 推荐     | 一劳永逸            |
| ✅ Pull Payment模式             | ✅ 推荐     | 更安全更清晰        |
| ❌ 用`transfer()`限制2300 gas   | ❌ 已不安全 | 部分合约可绕过限制  
