build HOST:
    nixos-rebuild switch --build-host hugo@{{HOST}} \
        --target-host hugo@{{HOST}} \
        --sudo --ask-sudo-password \
        --use-substitutes --no-reexec \
        --flake .
