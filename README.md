# Block Fixup Merge Action

Love using `git commit --fixup` to make minor cleanups to your Git history, but
forget to `git rebase -i --autosquash master` before merging?

Have I got a Github Action for you!

## Setup

Create a file in your project named: `.github/workflows/git.yml`

Add the following:

```yaml
name: Git Checks

on: [push]

jobs:
  block-fixup:
    runs-on: ubuntu-18.04

    steps:
    - name: Block Fixup Merge
      uses: 13rac1/block-fixup-merge-action@master
```

Optionally, setup Branch Protection to block merging of PRs against the `master`
branch with `!fixup` commits.

[![PR merge blocked](images/block-fixup-example.png?raw=true)](images/block-fixup-example.png?raw=true)
