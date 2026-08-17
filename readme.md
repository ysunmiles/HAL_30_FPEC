# HAL_30_FPEC

## 简介

本项目基于 **STM32F103** 系列微控制器与 **STM32 HAL 库**，演示了 STM32 内部 Flash（**FPEC**：Flash Program and Erase Controller）的页擦除、半字写入（Half-Word Programming）以及直接内存寻址读取功能。

程序在主循环中对指定的内部 Flash 地址进行周期性擦除与写入递增数据，并通过软件 I2C 驱动的 0.96 寸 OLED 屏幕实时显示“准备写入的数据”与“从 Flash 读出的数据”，直观展示 STM32 内部 Flash 的操作流程与非易失性特性。

---

## 主要功能与特性

1. **Flash 解锁与锁定**：
   - 写入和擦除前调用 `HAL_FLASH_Unlock()` 解锁 FPEC。
   - 操作完成后调用 `HAL_FLASH_Lock()` 锁定 Flash 控制器以防误操作。

2. **Flash 页擦除（Page Erase）**：
   - 配置 `FLASH_EraseInitTypeDef` 结构体，调用 `HAL_FLASHEx_Erase()` 擦除指定页面。
   - 调用 `FLASH_WaitForLastOperation()` 确保擦除操作执行完毕。

3. **Flash 半字编程（Half-Word Program）**：
   - 调用 `HAL_FLASH_Program(FLASH_TYPEPROGRAM_HALFWORD, ...)` 将 16 位（2 字节）数据写入目标地址。

4. **Flash 直接读取（Direct Read）**：
   - STM32 内部 Flash 统一编址在 `0x08000000` 起始空间，直接通过 C 语言指针解引用即可高效读取数据（如 `*pdata`）。

5. **OLED 状态实时显示**：
   - 软件 I2C 模拟驱动 0.96 寸 OLED（开漏输出模式）。
   - 实时显示待写入数据和 Flash 中实际读取的数据，每次循环自增并延时 1 秒。

---

## 硬件与引脚配置

### 1. 核心硬件
- **MCU**：STM32F103C8T6 / STM32F103 系列（Cortex-M3）
- **显示设备**：0.96 寸 OLED 屏幕（I2C 接口，SSD1306）

### 2. 引脚分配

| 外设 / 接口 | MCU 引脚 | 说明 |
| :--- | :--- | :--- |
| **OLED SDA** | `PB8` | 软件 I2C 数据线（GPIO 开漏输出） |
| **OLED SCL** | `PB9` | 软件 I2C 时钟线（GPIO 开漏输出） |
| **SWD 调试** | `PA13` (SWDIO) / `PA14` (SWCLK) | ST-Link / DAP-Link 烧录与调试 |

---

## Flash 内存规划与操作说明

- **Flash 基地址**：`0x08000000`
- **示例测试地址**：`0x08008000`（位于 32KB 偏移位置，第 32 页，避开常规用户代码区）
- **操作规则**：
  - Flash 写入前**必须**先擦除，擦除后对应存储单元全为 `0xFFFF`。
  - Flash 只能将位由 `1` 写为 `0`，不能直接将 `0` 改写为 `1`。
  - STM32F103 中容量产品（如 F103C8）单页大小为 **1KB (1024 字节)**。

---

## 目录结构

```text
HAL_30_FPEC/
├── CMakeLists.txt              # 根 CMake 构建文件
├── CMakePresets.json           # CMake 预设配置 (Debug / Release)
├── config.ioc                  # STM32CubeMX 项目配置文件
├── STM32F103XX_FLASH.ld        # 链接脚本
├── cmake/
│   ├── gcc-arm-none-eabi.cmake # ARM GCC 工具链配置
│   ├── user_sources.cmake      # 用户自定义源码与头文件包含配置
│   └── stm32cubemx/            # CubeMX 生成的构建子模块
├── Core/
│   ├── Inc/
│   │   ├── main.h              # 引脚定义与公共头文件
│   │   ├── gpio.h              # GPIO 声明
│   │   ├── OLED.h              # OLED 接口声明
│   │   └── OLED_Font.h         # OLED 字模字库
│   └── Src/
│       ├── main.c              # 主程序（FPEC 擦写与读取循环逻辑）
│       ├── gpio.c              # GPIO 初始化配置
│       ├── OLED.c              # 软件 I2C 与 OLED 显示实现
│       └── stm32f1xx_it.c      # 中断服务函数
└── Drivers/                    # STM32 HAL 驱动库与 CMSIS
```

---

## 构建与烧录

### 开发环境要求
- **CMake**：>= 3.22
- **Ninja** 构建器
- **交叉编译工具链**：`arm-none-eabi-gcc`
- **烧录工具**：OpenOCD / ST-Link Utility / pyOCD / STM32CubeProgrammer

### 命令行构建步骤

1. **配置工程**（选择 Debug 或 Release 预设）：
   ```bash
   cmake --preset Debug
   ```

2. **编译生成固件**：
   ```bash
   cmake --build --preset Debug
   ```
   编译产物将生成在 `build/Debug/` 目录下（包含 `.elf`、`.hex`、`.bin` 等）。

3. **固件烧录**：
   使用 ST-Link、J-Link 或 DAP-Link 将生成的固件烧录进 STM32 开发板。

---

## 实验现象

1. 烧录完成后系统复位运行。
2. OLED 屏幕显示如下：
   - **Line 1**：`FPEC`
   - **Line 2**：`DataToSave : 0001`（随后每秒递增：`0002`、`0003`...）
   - **Line 3**：`DataInFlash: 0001`（实时与待写入数据保持一致，验证 Flash 写入成功）
3. 即使开发板复位或重新上电，Flash 中指定地址仍会保留最后一次写入的数值。

---

## 许可证

本项目采用 [MIT License](LICENSE.txt) 许可。

