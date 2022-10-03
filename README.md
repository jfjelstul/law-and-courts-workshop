
# Law and Courts Immersion: Working with Large Databases: Intro to R

This repository contains materials for the **Intro to R** workshop at **Law and Courts Immersion: Working with Large Databases**.

In this workshop, we'll introduce you to using `R` to study law and courts. First, we'll cover the basics of using `R`, including how to use RStudio (a popular interface for `R`), how to write and run `R` scripts, what the various types of objects are in `R`, and how to use and write functions in `R`. 

Second, we'll talk about how to clean and manipulate data in `R`. We'll use the `tidyverse` — a suite of open source packages for manipulating data that have become the standard in data science. We'll talk about how to use a programming technique called "pipes" to make your code more efficient and more readable, how to sort data, how to filter data, how to select variables from datasets, how to manipulate variables, how to collapse and expand datasets, how to merge datasets, and how to reshape datasets. We'll also go over tools for working with text variables (called "strings" in `R`), date variables, and categorical variables (called "factors" in `R`). We'll use real data on EU infringement proceedings to illustrate how using `R` makes all of these tasks easier, faster, more reliable, and more replicable than doing it by hand.

Third, we'll introduce you to using `R` for data visualization using `ggplot2` — the most powerful, and popular, tool for creating visualizations in data science. We'll show you some examples of data visualizations made using `ggplot2` related to the empirical study of law and courts. We'll show you how to prepare data for visualization, how make a variety of basic plots, and how to customize the look and feel of your plots. We'll also use the `eumaps` package to make maps. We'll use the tutorial `tutorials/maps-tutorial.md`.

Fourth, we'll learn how to clean and manipulate text data in `R` to get it ready for analysis. We'll learn how to write regular expressions — a syntax for matching patterns in text data — and how to implement them in `R` using `stringr`. Regular expressions are critical for cleaning and manipulating text data, including making dummy variables that capture the presence or absence of certain content in legal documents. We'll use the tutorial `tutorials/regular-expressions-tutorial.rmd`.

You can find all of the `R` scripts for the workshop in the `workshop-scripts/` folder. You can look at examples of visualizations related to law and courts made using `ggplot2` in `visualization-examples.pdf`. You can find convenient cheatsheets for the `tidyverse` package we'll be using n the `tidyverse-cheetsheets` folder.

## Getting ready for the workshop

To actively participate in the workshop, you will need to install `R` and `RStudio` ahead of time. `R` is a programming language and RStudio is a interactive development environment (IDE) that makes `R` more convenient to use. Both `R` and RStudio are open source and free to download. Installing RStudio does not install `R` — you need to install `R` before you install RStudio.

### Installing R

To install `R`, go to `https://cloud.r-project.org/`. You want to install `R` using the precompiled binary distribution for your operating system. Select your operating system using on of these links:

<img src="https://github.com/jfjelstul/IHEID-R-workshop/blob/master/installation/install-R-1.png?raw=true" width="80%">

If you use macOS, click on this link to install the latest version of `R`:

<img src="https://github.com/jfjelstul/IHEID-R-workshop/blob/master/installation/install-R-2.png?raw=true" width="80%">

If you use Windows, and you haven't installed `R` before, click on this link:

<img src="https://github.com/jfjelstul/IHEID-R-workshop/blob/master/installation/install-R-3.png?raw=true" width="80%">

Then, click this link to install the latest version of `R`:

<img src="https://github.com/jfjelstul/IHEID-R-workshop/blob/master/installation/install-R-4.png?raw=true" width="80%">

### Installing RStudio

To install `RStudio` from `https://www.rstudio.com/products/rstudio/download/`. You want to download the free version of RStudio Desktop. Click on this link:

<img src="https://github.com/jfjelstul/IHEID-R-workshop/blob/master/installation/install-RStudio-1.png?raw=true" width="80%">

This will scroll you down to a button that will let you download the current version of RStudio for your operating system:

<img src="https://github.com/jfjelstul/IHEID-R-workshop/blob/master/installation/install-RStudio-2.png?raw=true" width="80%">

You can also choose the appropriate installer for your operating system from this list:

<img src="https://github.com/jfjelstul/IHEID-R-workshop/blob/master/installation/install-RStudio-3.png?raw=true" width="80%">
