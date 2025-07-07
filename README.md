# Welcome to Universus!

Universus is a **long-form × plinko × battle-sim** with deployable arcade machines in mind, built in [Godot 4.4 + .NET](https://godotengine.org/download/)

This was made as part of Ontario Tech University's Tech For Good program.


# how to github

> [!NOTE]
> *this section will be removed once the project is finished*

You must PR a feature branch in order to make changes to the `master` branch.

<details>
<summary>Click here if you're not sure what that means</summary>

Since we have lots of people working on this project, it would be a pretty big
headache if we all could push directly to the `master` branch 😅

To solve this issue, pushing to `master` is **🚫blocked**, and can only be committed
to via pull requests (PRs):

> Git commands are written below, but you can easily follow with the GitHub Desktop
> interface

<br/>

1. **Create and move to a new branch**

```sh
# the "feature/" part is not required, but it's one way to tell what the
# intention of the branch is (feature, bugfix, etc).

git checkout -b 'feature/mycoolfeature'  
```

<br/>

2. **Commit and push all your changes to that branch**

```sh
git add .
git commit -m 'biggest commit'
git push
```

> Since this is your branch, do whatever you want to it! Force-push, rebase, etc.

<br/>

3. **Create a PR!**

Go to the GitHub repo in the browser and navigate to "Pull Requests > New Pull Request"

You can optionally (but should) include information about what the PR is about inside the description

GitHub will tell you if there are any conflicts that will arise as a result of a hypothetical 
merge with the `master` branch. Use this to fix those conflicts!

<br/>

4. **Get a buddy**

Someone else must approve your PR before getting it merged to `master`.
Get someone from your field to review it for you.

If you're the one reviewing, you can navigate to their feature branch to ensure everything is
A-OK!

<br/>

5. **Profit!**

</details>
