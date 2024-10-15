# filament_tortuosity
A MATLAB script to analyze Imaris Filament object tortuosity


The script uses [ImarisReader](https://github.com/PeterBeemiller/ImarisReader.git), a set of MATLAB classes to read image and  segmentation object data stored in Imaris .ims files. 
*Work in progress; tested in MATLAB R2022b using an .ims file segmented in Imaris 10.2.*

The individual steps are as follows:

1. Clone the ImarisReader repository:
```bash
 git clone https://github.com/PeterBeemiller/ImarisReader.git
```

2. Add to Path in MATLAB and save.
   
3. Download and open `analyze_filament.m`.

4. Load the .ims file with a reconstructed Filament object: 
```bash
 xPath = 'path to your .ims file';
 imsObj = ImarisReader(xPath);
```

5. Retrieve Filament node positions and connectivity information:
```bash
 xFilaments = imsObj.Filaments(1);
 xFilamentsPositions = xFilaments.GetPositions(0);
 xFilamentsEdges = xFilaments.GetEdges(0)+1;
```

6. Construct a graph:
```bash
 G = graph(xFilamentsEdges(:,1), xFilamentsEdges(:,2));
 G.Nodes.X = xFilamentsPositions(:,1);  
 G.Nodes.Y = xFilamentsPositions(:,2); 
 G.Nodes.Z = xFilamentsPositions(:,3); 
```

7. Compute tortuosity between consecutive terminal and branch nodes. 
