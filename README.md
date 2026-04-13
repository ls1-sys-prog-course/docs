# Practical course: Systems Programming -- SoSe 2026

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
- Compiler/LLVM: How to implement LLVM passes to improve compiler-generated codes (**C++ only**)


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

- Preliminary meeting: Tues, Feb 11th @ 13:00 CET (Zoom)
    - [Slide](./slides/preliminary_meeting.pdf).
    - [Zoom link](https://tum-conf.zoom-x.de/j/67953460706?pwd=XIWf0KcUS4oJMURHATfiFu3FdEQNXr.1).
- Q&A session: Weekly on Thursday from 15:00 to 15:30 CEST online (zoom)
    - [Meet link](https://meet.google.com/wah-ctay-ggy).
    - The meeting starts exactly at 15:00 CEST but may finish earlier than 15:30 depending on the demand.

## Tasks

Please refer to the respective task repositories (that are released on the published date) for details.
The schedule may change. **Tasks are released on the publishing date at 15:00 (CEST)**. **All deadlines are at 15:00 (CEST)**.

<!-- Points column must match points.conf - this is the source of truth for grade.sh -->

| Task                                                                     | Organizer                                               | Published on | Deadline       | Points | Language | Slide                                          | Video                                                                         |
|--------------------------------------------------------------------------|---------------------------------------------------------|--------------|----------------|--------|----------|------------------------------------------------|-------------------------------------------------------------------------------|
| Introduction         | [Maximilian Jäcklein](https://github.com/karmagiel)       | 13.04.2026   | 20.04.2026     | 0      | C/C++, Rust | [Link](./slides/00-introduction.pdf)        |                                       |
| System Calls    | [Christian Krinitsin](https://github.com/karmagiel)       | 20.04.2026   | 27.04.2026     | 30     | C/C++, Rust | [Link](./slides/01-system_calls.pdf)        | Lecture                                       |
| File I/O          | [Christian Krinitsin](https://github.com/ludof63)         | 27.04.2026   | 11.05.2026     | 30     | C/C++, Rust | [Link](./slides/02-files.pdf), [FUSE](./slides/02-fuse.pdf) [Lecture](https://youtu.be/VgyHUqS_8Ro?si=nI9EqRIiLA9O9sXq)                                        |
| Processes      | [Christian Krinitsin](https://github.com/ludof63)         | 11.05.2026   |25.05.2026     | 30     | C/C++, Rust | [Link](./slides/03-processes.pdf)           | [Lecture](https://youtu.be/4EQL6I1A8BU?si=IL9ycV4rMFqHf9Kc)                                       |
| Concurrency  | [Maximilian Jäcklein](https://github.com/maxjae)        | 25.05.2026   | 08.06.2026     | 30     | C/C++, Rust | [Link](./slides/04-concurrency.pdf)         | [Lecture](https://youtu.be/-83VHl2AHV8?si=535M5B08QKJdQo9Y)                                      |
| Memory Management | [Maximilian Jäcklein](https://github.com/maxjae)        | 08.06.2026   | 22.06.2026     | 30     | C/C++, Rust | [Link](./slides/05-memory_management.pdf)   | [Lecture](https://youtu.be/R0OwCRPySAQ?si=cuihQV7tu4Ug5EIM)                                       |
| Networking       | [Victor Trost](https://github.com/TrostV)               | 22.06.2026   | 06.07.2026     | 30     | C/C++, Rust | [Link](./slides/06-network_programming.pdf) | [Lecture](https://youtu.be/dUqm5WZMM2M?si=i0CxJbrtHQjK7EnK)                                       |
| Compiler/LLVM  | [Victor Trost](https://github.com/TrostV)               | 06.07.2026   | 20.07.2026     | 30     | C++         | [Link](./slides/07-llvm.pdf)         | Lecture                                       |


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

All executables must run on Linux, x86_64. Therefore, we strongly recommend having a local Linux
x86_64 environment for development. Note that some tasks involve loading kernel modules and
configuring kernel parameters, including cgroups, and some operations are not allowed in some
container (docker) environments. While we only guarantee the execution of tasks in a local Linux
86_64 environment, if you are using different OSes, you can try to use a virtual machine.
Specifically, we recommend the following approaches:

- Windows: WSL2 works for many tasks. Also, Hyper-V, VirtualBox, and VMware can be used.
- Mac: If you use an Intel Mac, Docker for Mac works. If you use Arm mac (M-series), then you can
  try to use [utm](https://mac.getutm.app/) to emulate the entire x86_64 environment. Note that this
  incurs major overhead, which may affect your development.

In both cases, we recommend accessing the systems provided by the Rechnerhalle, which have been
tested in the past to work for sysprog tasks.

Each task gives more details information on runnable environments. Please note that you will be
graded only based on the test results in the CI, based on the last commit before the deadline.

## Grades

Grades are computed based on total points (210 max) as follows:

|From| To|Grade|
|----|---|-----|
|  0 | 84| 5.0 |
| 85 | 94| 4.7 |
| 95 |104| 4.3 |
|105 |124| 4.0 |
|125 |137| 3.7 |
|138 |149| 3.3 |
|150 |162| 3.0 |
|163 |172| 2.7 |
|173 |182| 2.3 |
|183 |192| 2.0 |
|193 |200| 1.7 |
|201 |206| 1.3 |
|207 |210| 1.0 |

## Communication Medium

We will use the official [Zulip chat](https://zulip.cit.tum.de/#narrow/channel/3511-SysProg---General) server hosted by TUM for all communication.

## Other resources

- [Youtube playlist](https://www.youtube.com/playlist?list=PLfKm1-FQibbB3U8jBJ5-mF3jmH0aCiQ7V)
- [Bugtracker](https://github.com/ls1-sys-prog-course/docs/issues)
- [Docker image](https://github.com/orgs/ls1-courses/packages/container/package/ls1-runner)
- [The previous semester (WiSe25)](https://github.com/ls1-sys-prog-course-archive-WiSe25/docs)
  - NOTE: The course material is being kept updated; therefore, the old version has differences.

## Contact

We *strongly* prefer Zulip for all communications. For any further questions/comments, please contact the course organizer(s):

- [Anubhav Panda](https://anubhavpanda.in/) 
- [Theofilos Augoustis](https://taugoust.github.io/)
- [Prof. Bhatotia](https://dse.in.tum.de/bhatotia/)

