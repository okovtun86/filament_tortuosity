%% 
% % % Install ImarisReader, a set of MATLAB classes to read image and 
% % % segmentation object data stored in Imaris .ims files.
% % % https://github.com/PeterBeemiller/ImarisReader.git
% % % 
% % % Run the script below to determine the diameter of Filament and tortuosity of individual Filament segments between terminal and branch points

xPath = 'Microglia-vasculature_Filament_loop_10pt2.ims';
imsObj = ImarisReader(xPath);

%% 
xFilaments = imsObj.Filaments(1);
xFilamentsPositions = xFilaments.GetPositions(0);
xFilamentsEdges = xFilaments.GetEdges(0)+1;

%% 
G = graph(xFilamentsEdges(:,1), xFilamentsEdges(:,2));
G.Nodes.X = xFilamentsPositions(:,1);  
G.Nodes.Y = xFilamentsPositions(:,2); 
G.Nodes.Z = xFilamentsPositions(:,3); 


%%
nodeDegrees = degree(G);
shortestPaths = distances(G);
graphDiameter = max(max(shortestPaths));

terminalNodes = find(nodeDegrees == 1);
branchPoints = find(nodeDegrees > 2);
keyNodes = sort([terminalNodes; branchPoints]);

tortuosityValues = [];
segmentCount = 0;

for i = 1:length(keyNodes)-1
    startNode = keyNodes(i);
    endNode = keyNodes(i+1);
   
    [shortestPath, pathLength] = shortestpath(G, startNode, endNode);
    
    if isempty(shortestPath)
        continue;
    end
    
    startPos = [G.Nodes.X(startNode), G.Nodes.Y(startNode), G.Nodes.Z(startNode)];
    endPos = [G.Nodes.X(endNode), G.Nodes.Y(endNode), G.Nodes.Z(endNode)];
    
    euclideanDist = norm(endPos - startPos);
    
    totalPathLength = 0;
    for k = 1:(length(shortestPath) - 1)
        node1 = shortestPath(k);
        node2 = shortestPath(k + 1);
        pos1 = [G.Nodes.X(node1), G.Nodes.Y(node1), G.Nodes.Z(node1)];
        pos2 = [G.Nodes.X(node2), G.Nodes.Y(node2), G.Nodes.Z(node2)];
        totalPathLength = totalPathLength + norm(pos2 - pos1);
    end
    
    if euclideanDist > 0
        segmentCount = segmentCount + 1;
        tortuosity = totalPathLength / euclideanDist;
        tortuosityValues = [tortuosityValues; startNode, endNode, tortuosity];
    else
        tortuosityValues = [tortuosityValues; startNode, endNode, NaN];  
    end
end

disp('Tortuosity between consecutive terminal and branch nodes:');
disp(array2table(tortuosityValues, 'VariableNames', {'StartNode', 'EndNode', 'Tortuosity'}));

%%
figure;
hold on;

for i = 1:size(xFilamentsEdges, 1)
    node1 = xFilamentsEdges(i, 1);
    node2 = xFilamentsEdges(i, 2);
    plot3([G.Nodes.X(node1), G.Nodes.X(node2)], [G.Nodes.Y(node1), G.Nodes.Y(node2)], [G.Nodes.Z(node1), G.Nodes.Z(node2)], 'r-', 'LineWidth', 2);
end

scatter3(G.Nodes.X(keyNodes), G.Nodes.Y(keyNodes), G.Nodes.Z(keyNodes), 25, 'filled');

xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D Graph with Terminal and Branch Nodes');
axis equal;
grid on;
hold off;
view(3);

%%
figure;

histogram(tortuosityValues(:,3),'Normalization','probability');
xlabel('Tortuosity');
ylabel('Segment Count');



