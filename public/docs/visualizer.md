## Intro

   This documentation will teach you how to add your visualization module into meta platform step by step.

   **Before you start**:
   1. you should have basic knowledge of Oviz.
   2. you should have basic knowlege of JavaScript(ES6), typescript.
   
   **After reading this**:
   1. You should be able to create a new visualizer module in meta_platform.
   


## System Overvirew

**Visualization mode**

The platform has 2 viz mode:
1. query_task
2. visualization - anlaysis

**Javscript Code Structure Overview**

      app
      └───javascript                      
          └───packs
          |   └───viz  
          |       └───scatterplot.js
          └───viz
              └───index.ts
              └───scatterplot
                  └───index.ts
                  └───template.bvt
                  └───editor.ts
                  └───data.ts
                  └───complex-scatterplot.ts

**Database Design Overview**

Some concepts:
1. Visualizer is the chart, e.g. scatterplot, heatmap...
2. Analysis refers to the deep omics analyis module, it has the concrete meaning. e.g. PCA, pathway enrichment...
3. A visualizer can be used by multiple analyses, for example, the scatterplot can be used by PCA and CCA.
4. A visualizer takes the analysis output files as input, these files called data sources in visualizer module.
5. An analyis may only use parts of the data sources. e.g. PCA won't have vector data. The binding of analysis to viz data sources is done by the files_info field of analyses.

**important conventions**

1. visualizer module name: 
    The module name is used to distinguish visualizers. The viz folder name, `MODULE_NAME` in index.ts, js pack name should all have the same name.
2. data type: 
    The `dataType` is the key of data sources. If you had used bvd-rails before, you should notice that the fileKey system design is different in meta_platform. In meta, the data source type should be the same as the fileKey of the data source, which means, one file can only be used for one visualizer and one analysis.

## Add a new visualizer

**Before you start** Clone the [meta project](https://delta.cs.cityu.edu.hk/chelijia/meta_platform) and install it.

### 1: Develop your visualizer module.


### 2: Add file.

#### 2.1: Develop you visualizer

The visualizer folder should contains these files, 
1. index.ts, the main javascript logic.
2. template.bvt, the template for drawing chart, written in oviz
3. editor.ts, the oviz editor related code.
4. data.ts, if the data processing is quite complicated, it is recommended to seperate the data processing logic from the `index.ts` into `data.ts`.
5. other customed components.

#### 2.2 index file conventions
  A index file must contain:
  ```typescript
  const MODULE_NAME = "scatterplot";

  function init() {
    if (!window.gon || window.gon.module_name !== MODULE_NAME)    
    return;
    ...
  };

  register(MODULE_NAME, init);

  export function registerScatterplot(){
      register(MODULE_NAME, init);
  }
  ```


#### 2.3: Register the visualizer

Now we have created our visualizer module, we need to tell the task_query module and analyis module how to use it.

1. register for task_query
Open 'app/javascript/viz/index.ts', inside `registerViz` function, add your case.
2. register for analysis
Create a new js file under 'app/javascript/packs', the js name should named by the MODULE_NAME

#### 2.4: Set the demo files



### 3: Add configs in admin panel.

#### 3.1 Add the visualizer and required viz data sources

Start the server, go to [admin:visualizer](localhost:3000/admin/visualizers). Please contact the project admin for account and password.

Click add visualizer to create a new visualizer, 
- fill in the name, 
- the js_module_name is your js pack name, this field must be , otherwise the platform cannot found the correct script file to load; 
- add the data sources you use, note that the dataType name must be the same as the dataType and fileKey in your code

Click `Create Visualizer` to submit the creation.


#### 3.2 Add the analysis

Go to [admin:analysis_categories](localhost:3000/admin/analysis_categoreis). If the analysis belongs to a existing analysis category, you can , otherwise you need to first create the analyis category, then create the analysis under that category.

Click add analysis to create a new analysis,
- fill in the name
- choose the visualizer for the analysis
- fill in the mid, the module id on deepomics, note that you can only have one analysis for one mid
- fill in the files_info json, the json format is : 
```json 
{
  "networkEdges": { // the data type
    "name": "Edges Data", //the data name displayed in file uploads panel
    "outputFileName": "Network_edges.xls", // the output file name by deep omics
    "demoFileName": "Network_edges.xls" // the demo file name
  },
  ...
}
```

Click `Create Analysis`

### Finished
  You can go to [localhost:3000/visualizer/analysis/{id}]() to see the chart.
