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
    parameters: any;
    globals: GlobalDef;
    steps: StepDef[]
    input: InputDef;
    output: InputDef
};
export type POWMessage = {
    type: string,
    message: string
}
export class POWResult {
  public success: boolean;
  public output: string;
  public object: object;
  public messages: any[];
  constructor(success: boolean, output: string, messages: any[], object: object) {
    this.success = success;
    this.output = output;
    this.object = object;
    this.messages = messages || [];
  }
}
export type POWError = {
    message: string,
    messages: string[]
}