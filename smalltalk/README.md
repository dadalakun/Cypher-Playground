# Smalltalk Visualizer

## 1. Prerequisite
* Install `NeoJSON` on Pharo to parse input JSON file

  ```
  "Pharo playground"
  Metacello new
    repository: 'github://svenvc/NeoJSON/repository';
    baseline: 'NeoJSON';
    load.
  ```

## 2. Test the visualizer
Replace `'/put/the/json/file/path'` with the absolute path of the json file
```
| reader parser jsonData graph visualizer |
reader := JsonReader new.
reader readFromFile: '/put/the/json/file/path'.
jsonData := reader jsonData.
jsonParser := JsonParser new.
graph := jsonParser parseJson: jsonData.

visualizer := GraphVisualizer new.
visualizer visualizeGraph: graph.
```

<img src='https://i.imgur.com/WUjLl8Y.png'>

## 3. Reference
NeoJSON
* https://github.com/svenvc/NeoJSON

Roassal
* https://github.com/pharo-graphics/Roassal
* https://github.com/pharo-graphics/RoassalDocumentation/tree/master