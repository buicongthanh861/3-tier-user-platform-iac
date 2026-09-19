kubectl apply -f ../argocd/applications/

Tạo 3 Argo CD Application tương ứng frontend, backend, database — mỗi application theo dõi nhánh master của repo Git, tự động sync và self-heal khi cluster bị drift.
