function costruzione_grafo(U, t, A, A_rec, options)
    arguments
        U, t, A, A_rec
        options.velocita (1,1) double = 0.05
    end

    % 1. Setup Dati
    [n_nodi, ~] = size(U{1});
    c_mat = pinv(U{1}, 1e-5);       % Matrice per i Ping
    x_coords = []; y_coords = [];   % Placeholder per coordinate
    CLIM_RANGE = [-0.1, 0.8];       % Scala colori fissa

    % 2. Setup Figura
    figure('Color', 'w', 'Position', [100, 100, 1200, 500]);
    colormap jet;

    % --- GRAFO SX (TARGET) ---
    subplot(1,2,1);
    h1 = plot(graph(A), 'Layout', 'force', 'NodeColor', 'b', 'MarkerSize', 7);
    x_coords = h1.XData; y_coords = h1.YData; % Congela coordinate
    title('Target'); axis off tight; colorbar; clim(CLIM_RANGE);

    % --- GRAFO DX (GENESI) ---
    subplot(1,2,2);
    h2 = plot(graph(zeros(n_nodi)), 'XData', x_coords, 'YData', y_coords, ...
              'NodeColor', 'b', 'MarkerSize', 7);
    title('Genesi'); axis off tight; colorbar; clim(CLIM_RANGE);

    fprintf('Avvio animazione...\n');

    %% Ciclo Animazione
    while true
        % Resetta la matrice ricostruita
        M_built = zeros(n_nodi); 
        
        for node = 1:n_nodi
            % Calcola diffusione per il nodo corrente
            coeff = c_mat(:, node);
            vicini = find(A_rec(node, :));
            
            for k = 1:min(12, length(U))
                % Calcola colore (temperatura)
                temp = U{k} * coeff;
                h1.NodeCData = temp;
                h2.NodeCData = temp;
                
                % --- AGGIUNTA ARCHI (solo al passo k=2) ---
                if k == 2 && ~isempty(vicini)
                    % Aggiungiamo i vicini alla matrice (logica booleana veloce)
                    new_edges = false;
                    for v = vicini
                        if M_built(node, v) == 0
                            M_built(node, v) = 1; M_built(v, node) = 1;
                            new_edges = true;
                        end
                    end
                    
                    % Se la matrice è cambiata, ridisegna il grafo
                    if new_edges
                        subplot(1,2,2);
                        h2 = plot(graph(M_built), 'XData', x_coords, 'YData', y_coords, ...
                                  'NodeColor', 'b', 'MarkerSize', 7, 'LineWidth', 1.5);
                        h2.NodeCData = temp; % Riapplica subito il colore
                        axis off tight; colorbar; clim(CLIM_RANGE); % Ripristina assi
                        title(sprintf('Genesi: Trovati collegamenti nodo %d', node));
                    end
                end
                
                sgtitle(sprintf('Ping Nodo %d - t=%.3f', node, t(k)));
                drawnow; pause(options.velocita);
            end
        end
        % Pausa fine ciclo
        sgtitle('Ricostruzione Completata! Riavvio...');
        pause(2);
        
        % Reset visuale grafo destro per il prossimo giro
        subplot(1,2,2);
        h2 = plot(graph(zeros(n_nodi)), 'XData', x_coords, 'YData', y_coords, ...
                  'NodeColor', 'b', 'MarkerSize', 7);
        axis off tight; colorbar; clim(CLIM_RANGE);
    end
end