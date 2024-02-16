<!-- omit in toc -->
# COMP 311: Final Project

In this project, you will implement three recursive MIPS procedures.

First, you will implement `bingen`, which prints the binary patterns of length `N` (e.g., for `N = 3`, `000`, `001`, ... , `111`). Then, you will implement a binary search tree's (BST) `insert` and `inorder` functions.

<details open>
  <summary>Overview</summary>

- [Pre-lab knowledge](#pre-lab-knowledge)
    - [Reference code](#reference-code)
    - [macros](#macros)
    - [Getting started](#getting-started)
    - [Advice](#advice)
- [`bingen`](#bingen)
    - [Example](#example)
- [BST](#bst)
    - [Understand given code](#understand-given-code)
    - [`insert`](#insert)
        - [Example](#example-1)
        - [Submit code](#submit-code)
    - [`inorder`](#inorder)
        - [Example](#example-2)
    - [Comments](#comments)
- [Submit your assignment](#submit-your-assignment)
</details>

## Pre-lab knowledge

### Reference code

Reference C code is provided in [reference/](reference/). `cd reference` and compile the programs with `make all` or `gcc`, if installed, and run to see what they do.

The autograder `diff`s the outputs of your MIPS program and the corresponding reference program when both are provided the same inputs, so any differences will result in no credit. Don't worry about leading/trailing spaces and newlines, which are removed via [`strip`](https://docs.python.org/3/library/stdtypes.html#str.strip).

The tests for `insert` and `inorder` do something different in addition to that, which will be explained later.

### macros

Two additions to [macros.asm](macros.asm):

1. One new macro for `bingen`: `print_str_label`. Two new macros for the BST implementation: `sbrk` and `new_node`.
2. All macros now use the stack to save and restore the `a` registers. Thus, you do not have to worry about the given macros clobbering `a` registers in your code.
    * As mentioned in the comments, this does not follow the MIPS caller-callee contracts because our macros usually behave like callees so should not save the `a` registers. However, this will make your life a lot easier.

### Getting started

If you don't know where to start with recursive code, review Template 1 (leaf procedure with minimal stack frame) given in the lecture slides about procedures and stacks. This one is particularly important because its 8 lines of code are reused in all other templates. You may also find it helpful to review the relevant PEW questions about procedures and stacks and the explanations posted in a Canvas announcement. Finally, the `sqr` program from lecture, slightly modified, is provided in [reference/lecture/](reference/lecture).

### Advice

When writing recursive MIPS assembly code for this project, you will not need to keep track of a lot of registers. For example, our solution code for `bst.asm` uses only one temporary register `$t0` to implement `insert`, in addition to the necessary ones: `$a0`, `$a1`, `$sp`, `$fp`, `$ra`, and `$v0`. Even though this may seem like a lot, the necessary ones shouldn't be hard to keep track of because they're part of our stack/procedure templates.

The difficulty is that you now have to handle saving and restoring registers, per the caller-callee contracts. Before and while writing code, keep the following in mind about the registers you use:

* If a register is clobbered, it probably needs to be saved and/or restored.
* If a register is never clobbered, it does not need to be saved or restored.
* How many temporary registers do you need, if any? If you need at least one, is it possible to reuse it? Using fewer registers may make coding easier since there'll be fewer things to focus on.

Before implementing a function, please write your planned stack frame (similar to the ones from lecture) in a brief comment above the function. Update the comment, if necessary. Something as simple as the following will help a lot.

```mips
# $fp -> $ra
#        $fp
#        $a1
# $sp -> $s0
```

Lastly, you shouldn't have to write a lot of code. The number of additional lines that our solution code has that isn't in the template code (including at least 24 (3*8) lines of boilerplate from Template 1) is

```text
$ diff -y --suppress-common-lines template/bingen.asm bingen.asm | wc -l
39
$ diff -y --suppress-common-lines template/bst.asm bst.asm | wc -l
70
```

## `bingen`

Use [bingen.c](reference/bingen.c) as a reference to implement `bingen` in [bingen.asm](bingen.asm).

### Example

```text
Enter the number of bits (1 <= N <= 16): 3
000
001
010
011
100
101
110
111
```

## BST

After reading the following, use [bst.c](reference/bst.c) as a reference to implement `insert` and `inorder` in [bst.asm](bst.asm).

Recall from COMP 210 that a BST is a binary tree where all values in the left subtree are less than the value at the root, and all values in the right subtree are greater than or equal to the value at the root.

In [bst.h](reference/bst.h), we represent this structure as

```c
typedef struct BST {
  int data;
  struct BST* left;
  struct BST* right;
} BST;
```

### Understand given code

Before implementing the BST functions, you must understand the macro `new_node` in [macros.asm](macros.asm). For a visual aid, see the heap memory diagram for the example BST insertions below.

In `new_node`, there are 4 simple self-check questions in comments that you should be able to answer before implementing the BST functions.

In short, although we are using a new system call `sbrk` that returns a pointer, a pointer is just a memory address. We have been working with memory addresses and pointer arithmetic using load and store instructions since the first MIPS lab, so this should feel really familiar.

Lastly, when comparing to `NULL`, simply write `NULL`. This is because of the line `.eqv NULL 0` in `macros.asm`.

### `insert`

In [bst.asm](bst.asm), implement `insert`.

#### Example

```text
Enter BST size: 5
Value: 2
Value: 5
Value: 1
Value: 3
Value: 4
Inorder: 
```

<p align="center">
    <img src="https://i.imgur.com/Is0iRBK.png">
</p>
<p align="center"><em>BST formed by insertions 2, 5, 1, 3, 4</em></p>

In the Execute menu's Data Segment, change the address to `0x00002000 (heap)`, and unset Hexadecimal Addresses and Hexadecimal Values.

<p align="center">
    <img src="https://i.imgur.com/3SCY6AJ.png">
</p>
<p align="center"><em>Settings</em></p>

You should see the following:

<p align="center">
    <img src="https://i.imgur.com/twfbL8x.png">
</p>
<p align="center"><em>Heap after inserting 2, 5, 1, 3, 4</em></p>

<p align="center">
    <img src="https://i.imgur.com/4EEmkSM.png">
</p>
<p align="center"><em>2 points to 1 (left) and 5 (right); 5 points to <code>NULL</code> (right)</em></p>

#### Submit code

Once you think `insert` works, submit to Gradescope. The autograder will run your code on certain inputs and dump heap memory. It will do the same for our reference assembly code and run a `diff`.

Do not start `inorder` without getting full points for `insert`. The `inorder` tests will also check heap memory so will fail if `insert` is not implemented correctly.

### `inorder`

Implement `inorder`.

#### Example

```text
Enter BST size: 5
Value: 2
Value: 5
Value: 1
Value: 3
Value: 4
Inorder: 1 2 3 4 5 
```

### Comments

* We will not implement [`free`](https://www.tutorialspoint.com/c_standard_library/c_function_free.htm), but you should be able to think of a simple strategy for doing so.
* Congrats on getting through all programming assignments! Good luck on the final exam.

## Submit your assignment

Assignments are submitted through [Gradescope](https://www.gradescope.com).

You should already be enrolled in the COMP 311 course on Gradescope. If you are not, please check the course website and syllabus for self-enrollment instructions. If you're unable to self-enroll, please contact your cohort leader(s) and we'll manually add you.

To submit your assignment, please follow the basic steps provided below. If you're unable to perform any of the steps, please reach out to your **cohort** and **cohort leader** as soon as possible. That is, give yourself time to resolve any technical issues using GitHub, GitHub Desktop, and Gradescope well before the assignment due date.

1. Submit modifications using the **commit** GitHub Desktop instructions.
2. Update remote (origin) repository using the **push** GitHub Desktop instructions.
3. Go to the COMP 311 course in Gradescope and click on the assignment called **Final Project**.
4. Click on the option to **Submit Assignment** and choose GitHub as the submission method. You may be prompted to sign in to your GitHub account to grant access to Gradescope. When this occurs, grant access to the Comp311 organization.
5. You should see a list of your public repositories. Select the one named **final-project-yourname** and submit it.
6. Your assignment should be autograded within a few seconds and you will receive feedback.
7. If you receive all the points, then you have completed the project! Otherwise, you are free to keep pushing commits to your GitHub repository and submit for regrading up until the deadline of the project.
