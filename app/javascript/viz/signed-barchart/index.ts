import Oviz from "crux";
import template from "./template.bvt"
import { editorConfig } from "./editor";
import { registerEditorConfig } from "utils/editor";

import {register} from "page/visualizers";
import {findBound} from "utils/maths";
import {minmax} from "crux/dist/utils/math"
import {signedChartColors} from "oviz-common/palette";


const MODULE_NAME = 'signed-barchart'


const fileContent = `Level	Zscore	Group
Starch and sucrose metabolism  	4.67230569087652	T0
Amino sugar and nucleotide sugar metabolism  	4.23513223596788	T0
Lipopolysaccharide biosynthesis  	4.18020055855861	T0
Aminoacyl-tRNA biosynthesis  	3.99680180431607	T0
RNA degradation  	3.87789104703691	T0
Other glycan degradation  	3.76527134254367	T0
Sphingolipid metabolism  	2.98154930807344	T0
RNA polymerase  	2.95699296067618	T0
Streptomycin biosynthesis  	2.8517832177851	T0
Alanine, aspartate and glutamate metabolism  	2.80091728876466	T0
Bacterial invasion of epithelial cells  	2.77961079594458	T0
Citrate cycle (TCA cycle)  	2.68004751043801	T0
Carbapenem biosynthesis  	2.55451900736333	T0
Polyketide sugar unit biosynthesis  	2.44709293138664	T0
Shigellosis  	2.38937819070092	T0
Fructose and mannose metabolism  	2.31682828653933	T0
Tuberculosis  	2.23661048769684	T0
Staphylococcus aureus infection  	2.20290065609869	T0
Carbon fixation in photosynthetic organisms  	2.0602802166275	T0
Acarbose and validamycin biosynthesis  	2.04249279926079	T0
beta-Lactam resistance  	1.99953188030805	T0
Carbon fixation pathways in prokaryotes  	1.96267932740957	T0
Oxidative phosphorylation  	1.89193857591761	T0
Legionellosis  	1.88691876292002	T0
Folate biosynthesis  	1.79277320522733	T0
Carotenoid biosynthesis  	1.78931202478229	T0
Salmonella infection  	1.77022322545431	T0
Sesquiterpenoid and triterpenoid biosynthesis  	1.70740436211367	T0
Fluorobenzoate degradation	-1.67608968706479	Healthy
Porphyrin and chlorophyll metabolism	-1.7804640382595	Healthy
Tyrosine metabolism	-1.86758189045506	Healthy
Glycerophospholipid metabolism	-1.87875422087998	Healthy
Pyrimidine metabolism	-1.90935714603239	Healthy
Biosynthesis of unsaturated fatty acids	-2.26200426629822	Healthy
Bacterial secretion system	-2.40234660074463	Healthy
Benzoate degradation	-2.72840889844352	Healthy
Bacterial chemotaxis	-2.98457397070002	Healthy
Phenylalanine metabolism	-3.40770363685142	Healthy
Flagellar assembly	-4.72941373889132	Healthy
ABC transporters	-5.44246168775253	Healthy`;


function init() {
    console.log("here at index ===>")
    if (!window.gon || window.gon.module_name !== MODULE_NAME) return;

    const {visualizer} = Oviz.visualize({
        el: "#canvas",
        template: `
        svg {
            width = 100; height = 100
            Rect.full;
        }
        `,
        theme: "light",
        data: {
            colors: {
                ...signedChartColors,
            },
            config : {
                plotHeight: 600,
                plotWidth: 800,
                barWidth: 15,
            }
        },
        // loadData:  {
        //     barchartData: {
        //         // fileKey: `barchartData`,
        //         // fileKey: `pathway`,
        //         // content: "../../../data/pathway.xls",
        //         content:  fileContent,
        //         type: "tsv" ,
        //         dsvRowDef: {Zscore: ["float"]},
        //         loaded(data) {
        //             console.log("loading data...")
        //            const valueRange = minmax(data, "Zscore");
        //            const lowerBound = -findBound(valueRange[0]*-1,0,1);
        //            const upperBound = findBound(valueRange[1],0,1);
        //            this.data.axisPos = -lowerBound/(upperBound - lowerBound)
        //            this.data.plotHeight = 15 * data.length;
        //            this.data.bounds = {lowerBound, upperBound};
        //         },
        //     },
        // },
        setup() {
            this.data.plotHeight = this.data.config.plotHeight;
            this.data.plotWidth = this.data.config.plotWidth;
            registerEditorConfig(editorConfig(this));
        }
        
    });
    return visualizer;
}

// export function registerSignedBarChart() {
//     register(MODULE_NAME, init);
// }

register(MODULE_NAME, init);
