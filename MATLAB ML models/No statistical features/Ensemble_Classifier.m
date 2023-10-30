function [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
% [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
% Returns a trained classifier and its accuracy. This code recreates the
% classification model trained in Classification Learner app. Use the
% generated code to automate training the same model with new data, or to
% learn how to programmatically train models.
%
%  Input:
%      trainingData: A table containing the same predictor and response
%       columns as those imported into the app.
%
%
%  Output:
%      trainedClassifier: A struct containing the trained classifier. The
%       struct contains various fields with information about the trained
%       classifier.
%
%      trainedClassifier.predictFcn: A function to make predictions on new
%       data.
%
%      validationAccuracy: A double representing the validation accuracy as
%       a percentage. In the app, the Models pane displays the validation
%       accuracy for each model.
%
% Use the code to train the model with new data. To retrain your
% classifier, call the function from the command line with your original
% data or new data as the input argument trainingData.
%
% For example, to retrain a classifier trained with the original data set
% T, enter:
%   [trainedClassifier, validationAccuracy] = trainClassifier(T)
%
% To make predictions with the returned 'trainedClassifier' on new data T2,
% use
%   [yfit,scores] = trainedClassifier.predictFcn(T2)
%
% T2 must be a table containing at least the same predictor columns as used
% during training. For details, enter:
%   trainedClassifier.HowToPredict

% Auto-generated by MATLAB on 02-Oct-2023 17:02:51


% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'Freq', 'Dist_seg', 'CC_Tx_Tx', 'CC_Rx_Tx', 'CC_Rx_Rx', 'L_Tx_Tx', 'L_Rx_Tx', 'L_Rx_Rx', 'R_Tx_Tx', 'R_Rx_Tx', 'R_Rx_Rx', 'CC_TxRx_Dev', 'L_Txx_Dev', 'L_TxRx_Dev', 'L_Rxx_Dev', 'R_Txx_Dev', 'R_TxRx_Dev', 'R_Rxx_Dev'};
predictors = inputTable(:, predictorNames);
response = inputTable.DeformationType;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
classNames = categorical({'D1'; 'D2'; 'D3'; 'none'});

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
template = templateTree(...
    'MaxNumSplits', 10382, ...
    'NumVariablesToSample', 'all');
classificationEnsemble = fitcensemble(...
    predictors, ...
    response, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 30, ...
    'Learners', template, ...
    'ClassNames', classNames);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
ensemblePredictFcn = @(x) predict(classificationEnsemble, x);
trainedClassifier.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedClassifier.RequiredVariables = {'CC_Rx_Rx', 'CC_Rx_Tx', 'CC_TxRx_Dev', 'CC_Tx_Tx', 'Dist_seg', 'Freq', 'L_Rx_Rx', 'L_Rx_Tx', 'L_Rxx_Dev', 'L_TxRx_Dev', 'L_Tx_Tx', 'L_Txx_Dev', 'R_Rx_Rx', 'R_Rx_Tx', 'R_Rxx_Dev', 'R_TxRx_Dev', 'R_Tx_Tx', 'R_Txx_Dev'};
trainedClassifier.ClassificationEnsemble = classificationEnsemble;
trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2023a.';
trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  [yfit,scores] = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'Freq', 'Dist_seg', 'CC_Tx_Tx', 'CC_Rx_Tx', 'CC_Rx_Rx', 'L_Tx_Tx', 'L_Rx_Tx', 'L_Rx_Rx', 'R_Tx_Tx', 'R_Rx_Tx', 'R_Rx_Rx', 'CC_TxRx_Dev', 'L_Txx_Dev', 'L_TxRx_Dev', 'L_Rxx_Dev', 'R_Txx_Dev', 'R_TxRx_Dev', 'R_Rxx_Dev'};
predictors = inputTable(:, predictorNames);
response = inputTable.DeformationType;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
classNames = categorical({'D1'; 'D2'; 'D3'; 'none'});

% Perform cross-validation
partitionedModel = crossval(trainedClassifier.ClassificationEnsemble, 'KFold', 5);

% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
