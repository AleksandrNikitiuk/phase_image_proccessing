function [fpr,tpr,thresholds,auc,sensitivity,specificity,accuracy,confusion_matrix] = perform_paired_sample_roc_analysis(sample_1,sample_2);
% Функция для выполнения двухвыборочного ROC-анализа.

% Объединение выборок и их разметка
samples = [sample_1; sample_2];
labels = [zeros(size(sample_1)); (zeros(size(sample_2)) + 1)];

% Расчет характеристик кривой ошибок
[fpr,tpr,thresholds,auc,optimal_roc_point] = perfcurve(labels,samples,0);
n_optimal_roc_point = find(tpr == optimal_roc_point(2),1);

% Расчет матрицы сопряженности, чувствительности, специфичности и точности
predictions = samples;
predictions(predictions < thresholds(n_optimal_roc_point)) = 0;
predictions(predictions >= thresholds(n_optimal_roc_point)) = 1;
confusion_matrix = confusionmat(labels,predictions);
sensitivity = confusion_matrix(1,1)/(confusion_matrix(1,1) + confusion_matrix(1,2));
specificity = confusion_matrix(2,2)/(confusion_matrix(2,1) + confusion_matrix(2,2));
accuracy = (confusion_matrix(1,1) + confusion_matrix(2,2)) / (sum(sum(confusion_matrix)));

end

