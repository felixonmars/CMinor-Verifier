using System.Diagnostics.Contracts;
using System.Collections.Generic;

namespace cminor
{
    class BasicPath
    {
        public Expression headCondition = default!;
        public List<Expression> headRankingFunction = default!;

        // only assumement, assignment are allowed
        public List<Statement> statements = default!;

        public Expression tailCondition = default!;

        // null 表示没有啦
        public List<Expression> tailRankingFunction = new List<Expression>();

        [ContractInvariantMethod]
        void ObjectInvariant()
        {
            Contract.Invariant(headCondition.type is BoolType);
        }
    }
}