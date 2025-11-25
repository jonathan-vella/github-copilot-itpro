# Demo Script: Diagrams as Code

## Pre-Demo Setup

1. Ensure Python is installed.
2. Install the `diagrams` library: `pip install diagrams`.
3. Ensure Graphviz is installed (`sudo apt-get install graphviz` on Linux, `brew install graphviz` on Mac, or via installer on Windows).

## Demo Flow

### 1. Introduction (2 mins)

Explain the concept of "Diagrams as Code".

- "We treat infrastructure as code, why not diagrams?"
- "Binary files like Visio are hard to version control."
- "Python `diagrams` library lets us draw with code."

### 2. Using Copilot to Generate the Code (5 mins)

1. Create a new file named `my_architecture.py`.
2. Open Copilot Chat or use inline chat (`Ctrl+I`).
3. Prompt:
   > "Create a Python script using the 'diagrams' library to draw an Azure architecture. It should have an Azure DNS pointing to a Load Balancer. The LB connects to a VM Scale Set for the Web Tier. The Web Tier connects to an App Service. The App Service connects to Azure SQL Database and Redis Cache. Group them into logical clusters."

4. Watch Copilot generate the imports and the code structure.
5. Run the script: `python my_architecture.py`.
6. Show the generated PNG image.

### 3. Iterating with Copilot (3 mins)

1. Ask Copilot to modify the diagram.
   > "Update the script to add Application Insights monitoring connected to the App Service, and put the database and cache inside a 'Data Tier' cluster."

2. Run the script again and show the updated diagram.

### 4. Conclusion

- Diagrams are now version controlled.
- Consistent styling.
- Easy to update.
