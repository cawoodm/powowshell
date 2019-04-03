export type PipelineParamDef = { "default": string;  "type": string};
export type GlobalDef = { [key:string]: string};
export type StepParamDef = { "default": string;  "type": string};
export type StepDef = { id: string; name: string; reference: string; input: string; parameters: StepParamDef[]};
export type InputDef = {}; // TODO: Define pipeline I/O properly
export type OutputDef = {};
export type PipelineDef =  {
    id: string;
    name: string;
    description: string;
    parameters: PipelineParamDef[]
    globals: GlobalDef;
    steps: StepDef[]
    input: InputDef;
    output: InputDef
};
export type POWMessage = {
    type: string,
    message: string
}
export type POWResult = {
    success: boolean,
    output: string,
    object: any,
    messages: POWMessage[]
}