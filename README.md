`posenet` directory and related files copied from [here](https://github.com/tensorflow/tfjs-models/tree/master/posenet)

```
cd posenet
yarn
yarn build && yarn yalc publish
cd demo
yarn
yarn yalc link @tensorflow-models/posenet
yarn watch
```
To get future updates from the posenet source code:
```
# cd up into the posenet directory
cd ../
yarn build && yarn yalc push
```