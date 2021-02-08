import {defaultLayoutConf as conf} from "utils/editor"
import { genDefaultPalette, withDefaultPalette } from "oviz-common/palette";
import { EditorDef } from "utils/editor";
import { copyObject } from "utils/object";

function run(v) {
    v.forceDraw = true;
    v.run();
}
export const editorRef = {} as any;

const cbpPalette = {
    cBioPortal: {
        name: "cBioPortal",
        // miss, inframe, trunc, other, text, active layer, line, icon stroke
        colors: ["#3d7f08", "#913810", "#000000", "#c55ebc", "#000000", "#777", "#555", "#fff"],
    },
};

export function editorConfig(v): EditorDef {
    const [defaultPalette] = genDefaultPalette(v.data.colors);
    console.log(v.data.availableAxises);
    return {
        sections: [
            {
                id: "data",
                title: "Data",
                layout: "tabs",
                tabs: [
                    {
                        id: "gData",
                        name: "General",
                        view: {
                            type: "list",
                            items: [
                                {
                                    title: "Taxonomic rank",
                                    type: "select",
                                    options: v.data.ranks,
                                    value: {
                                        current: v.data.config.rankIndex.toString(),
                                        callback(d) {
                                            v.data.config.rankIndex = parseInt(d);
                                            const rankLabel = v.data.ranks[parseInt(d)].text;
                                            v.data.boxData = v.data.mainDict[rankLabel];
                                            v.forceRedraw = true;
                                            run(v);
                                        },
                                    },
                                },
                                {
                                    title: "Range Lower Bound",
                                    type: "input",
                                    value: {
                                        current: 0,
                                        callback(d) {
                                            v.data.boxData.valueRange[0] = parseFloat(d);
                                            run(v);
                                        },
                                    },
                                },
                                {
                                    title: "Range Upper Bound",
                                    type: "input",
                                    value: {
                                        current: 0,
                                        callback(d) {
                                            v.data.boxData.valueRange[1] = parseFloat(d);
                                            run(v);
                                        },
                                    },
                                },
                            ]
                        }
                    },
                ]
            },
            {
                id: "settings",
                title: "Settings",
                layout: "single-page",
                view: {
                    type: "list",
                    items: [
                        {
                            type: "vue",
                            title: "",
                            component: "color-picker",
                            data: {
                                title: "Customize colors",
                                scheme: copyObject(v.data.colors),
                                palettes: withDefaultPalette(defaultPalette, cbpPalette),
                                paletteMap: {"0":0,"1":1},
                                id: "pwcolor",
                                callback(colors) {
                                    v.data.colors = [colors['0'], colors['1']];
                                    run(v);
                                },
                            },
                        },
                        {
                            title: "X label rotation angle: ",
                            type: "input",
                            value: {
                                current: v.data.config.xLabelRotation,
                                callback(d) {
                                    v.data.config.xLabelRotation = parseFloat(d);
                                    run(v);
                                },
                            },
                        },
                        {
                            title: "Outliers",
                            type: "checkbox",
                            value: {
                                current: v.data.config.showOutliers,
                                callback(d) {
                                    v.data.config.showOutliers = d;
                                    run(v);
                                },
                            },
                        },
                    ],
                },
            },
        ],
    };
}
