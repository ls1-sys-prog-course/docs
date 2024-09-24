# Practical course: Systems Programming -- WiSe 2024/25

<!-- TODOs for WiSe24

- Update Zoom Links
- Update task release schedule

- Set-up github classrom
- Set-up local runners
- Invite other chair members

-->

## Chair website

- The practical course is organized by the [Chair of Distributed Systems & Operating Systems](https://dse.in.tum.de/) at TU Munich.

## Course Information
- Language: English
- Type: Practical training
- Module: IN0012, IN2106, IN2128
   - (_*This course is not offered to IN2397*_)
- SWS: 6
- ECTS Credits: 10
- Prerequisites:
    - We don't have any compulsory prerequisites, but we prefer students to be proficient in the basic concepts of operating systems and systems programming (C/C++/Rust).
    - Preferred knowledge or equivalent to the lectures:
        - Fundamentals of Programming (IN0002)
        - Introduction to Computer Architecture (IN0004)
        - Basic Principles: Operating Systems and System Software (IN0009)
- Course Material:
    - The Linux Programming Interface – Michael Kerrisk
    - Linux System Programming – Robert Love
- TUM Online: You must register for this course in TUM Online before the course starts
- Student note: Compulsory enrollment after two weeks of the matching outcome; students who fail to de-register in this period will be registered for the exam

## Course Details
This course covers some of the most important aspects of systems programming.
More specifically, we will cover the following topics through a set of programming assignments over the semester:

- Kernel and system calls: How programs interact with the operating system, how to implement some system calls yourself in assembly
- File I/O: Learn about file descriptors, direct i/o, memory mapped i/o, page cache etc.
- Concurrency and synchronization: Learn about different threading primitives, i.e., mutexes, concurrent data structure design, and how they are implemented
- Processes: Different system calls related to process handling like fork(), execve(), wait()
- Memory management: How virtual memory, heap, stack, and how malloc() works
- Networking: How to handle network protocols, efficient ways to implement servers
- Performance: How to bring out the performance of the hardware (**C++ only**)
- Compiler/LLVM: Hom to implement LLVM passes to improve compiler-generated codes (**C++ only**)


This course consists of a set of modules related to different aspects of systems programming.
For each of these modules, there is a dedicated assignment that will help students dig deeper into the concepts and get familiar with them with actual, useful, hands-on tasks.
There is also a weekly Q&A meeting where we answer students' questions and discuss the specific goal of each assignment.
The students will be required to perform tasks within a time frame (around 2-3 weeks, depending on the task) and submit their work in the online evaluation system.
The submitted workpieces will then be evaluated, and based on that, a grade will be calculated for each assignment.

## Objectives
- Introduction to a variety of operating system concepts
- Techniques for debugging and optimization of low-level code
- Good understanding of memory- and resource management

## Meeting place

- Preliminary meeting: July 4th, 2024 13:00 CEST (Zoom)
    - [Slide](./slides/preliminary_meeting.pdf)
    - [Zoom link](https://tum-conf.zoom-x.de/j/63212709724?pwd=lfDwbHWRKH8WY8CI6zB36EtWQUrSCe.1)
- Q&A session: Weekly on Thursday from 03:00 PM to 04:00 PM CET online (zoom)
    - [Zoom link](https://tum-conf.zoom-x.de/j/)

## Tasks

Please refer to the respective task repositories (that are released on the published date) for details.
The schedule may change. **All deadlines are at 15:00 (CEST).**

| Task                                                                     | Organizer                                         | Published on | Deadline | Points | Language | Slide                                       | Video                                                                         |
|--------------------------------------------------------------------------|---------------------------------------------------|--------------|----------|--------|----------|---------------------------------------------|-------------------------------------------------------------------------------|
| [Introduction](https://github.com/ls1-sys-prog-course/task0-sort)        | [Theofilos Augoustis](https://github.com/taugoust)| 14.10.2024     | 28.10.2024 | 0      | C/C++, Rust | [link](./slides/00-introduction.pdf)        | [Lecture]( https://youtu.be/Kv8OgLs1crI)                                      |
| [System Calls](https://github.com/ls1-sys-prog-course/task1-syscalls)    | [Jinwen Pan](https://github.com/JinwenPan)        | 21.10.2024     | 04.11.2024 | 30     | C/C++, Rust | [link](./slides/01-system_calls.pdf)        | [Lecture](https://youtu.be/qO33G1od3Xo)                                       |
| [File I/O](https://github.com/ls1-sys-prog-course/task2-fileio)          | [Jinwen Pan](https://github.com/JinwenPan)        | 28.10.2024     | 11.11.2024 | 30     | C/C++, Rust | [link](./slides/02-files.pdf), [FUSE](./slides/02-fuse.pdf)               | [Lecture](https://youtu.be/wDPH8DYZwCg), [FUSE](https://www.youtube.com/watch?v=i3YJK3es-iQ)                                        |
| [Processes](https://github.com/ls1-sys-prog-course/task3-processes)      | [Theofilos Augoustis](https://github.com/taugoust)| 04.11.2024     | 18.11.2024 | 30     | C/C++, Rust | [link](./slides/03-processes.pdf)           | [Lecture](https://youtu.be/qNzgterdPng)                                       |
| [Concurrency](https://github.com/ls1-sys-prog-course/task4-concurrency)  | [Theofilos Augoustis](https://github.com/taugoust)| 11.11.2024     | 25.11.2024 | 30     | C/C++, Rust | [link](./slides/04-concurrency.pdf)         | [Lecture](https://youtu.be/Bj-1pFh8Bck)                                       |
| [Memory Management](https://github.com/ls1-sys-prog-course/task5-memory) | [Simon Kammermeier](https://github.com/Simon04090)| 18.11.2024     | 02.12.2024 | 30     | C/C++, Rust | [link](./slides/05-memory_management.pdf)   | [Lecture](https://youtu.be/1LxVzohqRx0)                                       |
| [Networking](https://github.com/ls1-sys-prog-course/task6-sockets)       | [Simon Kammermeier](https://github.com/Simon04090)| 25.11.2024     | 09.12.2024 | 30     | C/C++, Rust | [link](./slides/06-network_programming.pdf) | [Lecture](https://youtu.be/fDRaXnhjoDE)                                       |
| [Performance](https://github.com/ls1-sys-prog-course/task7-performance)  | [Hendrik Hübner](https://github.com/HendrikHuebner)| 02.12.2024    | 16.12.2024 | 40     | C++         | [link](./slides/07-performance.pdf)         | [Lecture](https://youtu.be/o1SkOoCyHDI)                                       |
| [Compiler/LLVM](https://github.com/ls1-sys-prog-course/task8-llvm)       | [Hendrik Hübner](https://github.com/HendrikHuebner)| 09.12.2024    | 23.12.2024 | 30     | C++         | [link](./slides/08-llvm.pdf)                | [Lecture](https://youtu.be/7SSkksFEKfk)                                       |


Note that
- 100% points lost if private tests detect cheating or we find a solution tries to game the system (modifying test scripts, etc.)
- 50% points lost if normal private tests fail


## Allowed Libraries

In general, only standard libraries can be used. In addition to this, the following libraries are available for use.

- Rust: [libc](https://crates.io/crates/libc), [nix](https://crates.io/crates/nix)
- C++: [{fmt}](https://fmt.dev/latest/index.html), [range-v3](https://github.com/ericniebler/range-v3)
- General argument parsing libraries, such as [clap](https://crates.io/crates/clap)
- General error handling libraries, such as [anyhow](https://docs.rs/anyhow/latest/anyhow/)

Depending on the task, the use of additional libraries may be allowed or the use of libraries (including standard libraries) may be restricted. Please refer to the task description for details.


For a reference of the standard library, check out:
- [cppreference](https://en.cppreference.com/w/) for C/C++
- [std](https://doc.rust-lang.org/std/) for rust

## Environment

All executables must run on Linux, x86_64. Therefore, we strongly recommend having a local Linux x86_64 environment for development.
Note that some tasks involve loading kernel modules and configuring kernel parameters, including cgroups, and some operations are not allowed in some container (docker) environments.
While we only guarantee the execution of tasks in a local Linux 86_64 environment, if you are using different OSes, you can try to use a virtual machine. More specifically,

- Windows: WSL2 would work. Also, Hyper-V, VirtualBox, and VMware are available.
- Mac: If you use Intel Mac, Docker for Mac would work. If you use Arm mac (M1/M2), then you can try to use [utm](https://mac.getutm.app/) to emulate the entire x86_64 environment, though the overhead of full system emulation is huge, and some tests may not pass. So we recommend preparing other environments.

Some tasks are doable in [Github Codespaces](https://github.com/features/codespaces), which are free for students.
However, some tasks are not doable as they require the kernel's permission.

Each task gives more details information on runnable environments.
Note that only the test results on CI count toward grading.

## Grades

Grades are computed as follows:

|From| To|Grade|Interval|
|----|---|-----|-----|
|  0 |100| 5.0 | 100 |
|101 |112| 4.7 |     |
|113 |124| 4.3 |     |
|125 |148| 4.0 |     |
|149 |163| 3.7 |     |
|164 |178| 3.3 |     |
|179 |193| 3.0 |     |
|194 |205| 2.7 |  12 |
|206 |217| 2.3 |     |
|218 |229| 2.0 |     |
|230 |238| 1.7 |   9 |
|239 |245| 1.3 |   7 |
|246 |250| 1.0 |   5 |

## Slack workspace

We will use Slack for all communication. Please enroll in our Slack workspace using your official TUM email address.

- **Slack workspace:** https://ls1-courses-tum.slack.com
- **Slack channel:** #ws-24-sys-prog

## Other resources

- [Youtube playlist](https://www.youtube.com/playlist?list=PLfKm1-FQibbB3U8jBJ5-mF3jmH0aCiQ7V)
- [Bugtracker](https://github.com/ls1-sys-prog-course/docs/issues)
- [Docker image](https://github.com/orgs/ls1-courses/packages/container/package/ls1-runner)
- [The previous semester (WiSe23)](https://github.com/ls1-sys-prog-course-archive-WiSe23/docs)
  - NOTE: The course material is being kept updated; therefore, the old version has differences.

## Contact

We *strongly* prefer Slack for all communications. For any further questions/comments, please contact the course organizer(s):

- [Anatole Lefort](https://anatolelefort.net/)
- [Atsushi Koshiba](https://atsushikoshiba.github.io/)
- [Prof. Bhatotia](https://dse.in.tum.de/bhatotia/)
