function [m, q] = regressione_lineare(t, u)
    % Definisco la matrice X
    X = [t(:), ones(length(t), 1)];
    
    % Risolvo il sistema
    B = X \ u(:);
    
    % Assegno i valori alle variabili di output
    m = B(1);
    q = B(2);
end