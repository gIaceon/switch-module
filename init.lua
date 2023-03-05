export type SwitchAcceptedStatementType = any?;
export type DefaultType = {};
export type CaseType = ({[number]: SwitchAcceptedStatementType}) -> {[number]: SwitchAcceptedStatementType};
export type PassedTable = {[CaseType | DefaultType]: (SwitchAcceptedStatementType, SwitchAcceptedStatementType) -> (...any?)};
export type EvalutateFunctionType = (PassedTable, SwitchAcceptedStatementType) -> ();

local function DefaultEvaluateSwitchCase(Args, Passed_Argument: SwitchAcceptedStatementType): EvalutateFunctionType
	for _,v in ipairs(Args) do
		if (Passed_Argument == v) then
			-- if its the passed argument
			return true, v;
		end;
	end;

	return false, nil;
end;

local Default: DefaultType = {};
local Case: CaseType = function(Args)
	if (type(Args) == "table") then
		return Args;
	end;
	return {Args};
end;

local mt = {
	__index = {
		Default = Default;
		Case = Case;
		DefaultEvaluateSwitchCase = DefaultEvaluateSwitchCase;
	},
	__call = function(self, Passed_Argument: SwitchAcceptedStatementType?, EvalutateFunction: EvalutateFunctionType?)
		return function (Passed_Table: PassedTable)
			EvalutateFunction = EvalutateFunction or DefaultEvaluateSwitchCase;
			for CaseOrDefault, CaseFunction in pairs(Passed_Table) do
				-- Skip default case
				if (CaseOrDefault == self.Default) then continue; end;
				local Done, Equal = EvalutateFunction(CaseOrDefault, Passed_Argument);
				if (Done == true) then return CaseFunction(Equal, Passed_Argument); end;
			end;
			if (not Passed_Table[Default]) then
				return;
			end;
			return (Passed_Table[Default])(Passed_Argument);
		end;
	end;
};

return setmetatable({}, mt);
