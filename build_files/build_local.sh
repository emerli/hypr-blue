  podman build --no-cache -f Containerfile.hyprland -t hypr-blue:local .
  podman tag hypr-blue:local localhost:5000/hypr-blue:latest
  podman push --tls-verify=false localhost:5000/hypr-blue:latest
