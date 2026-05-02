function deicingServers = buildDeicingServers(policy)
    % BUILDDEICINGSERVERS Constructs de-icing servers according to the chosen policy.
    templateServerStruct = buildTemplateServerStruct();
    deicingServers = repmat(templateServerStruct, policy.k, 1);

    for i = 1 : policy.k
        deicingServers(i).id = i;
    end
end