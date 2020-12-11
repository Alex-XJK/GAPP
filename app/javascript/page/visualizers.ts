import { event } from "crux/dist/utils";

declare global {
    interface Window {
        __BVD3_visualizers: Record<string, () => void>;
    }
}

export function register(name: string, action: () => void) {
    if (!window.__BVD3_visualizers) window.__BVD3_visualizers = {};
    window.__BVD3_visualizers[name] = action;
    event.emit("bvd3-resource-loaded");
}

export function call(name: string): any {
    return window.__BVD3_visualizers[name]();
}

document.addEventListener("turbolinks:load", () => {
    if (window.__BVD3_visualizers[window.gon.module_name]) {
        event.emit("bvd3-resource-loaded");
    }
});
