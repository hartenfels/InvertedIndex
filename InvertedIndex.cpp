#include <functional>
#include <list>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>
// to avoid conflict with a macro in perl
#undef seed
#include <algorithm>

// oh yeah C++
typedef std::back_insert_iterator<std::list<int> >           OutIt;
typedef std::list<int>::const_iterator                        InIt;
typedef std::function<OutIt (InIt, InIt, InIt, InIt, OutIt)> RowOp;


class Row
{
public:

    void add_id(int id)
    {
        if (ids.empty() || ids.back() < id)
        {
            ids.push_back(id);
        }
        else if (ids.back() > id)
        {
            auto it = ids.begin();

            while (*it < id)
            {   ++it; }

            if (*it != id)
            {   ids.insert(it, id); }
        }
    }


    SV* listref()
    {
        AV* arr = newAV();
        for (int i : ids)
        {
            av_push(arr, newSViv(i));
        }
        return newRV_noinc(reinterpret_cast<SV*>(arr));
    }


    void op_with(const Row* rhs, RowOp op)
    {
        std::list<int> out;
        op(     ids.begin(),      ids.end(),
           rhs->ids.begin(), rhs->ids.end(),
           std::back_inserter(out));
        ids = out;
    }

    void and_with(const Row* rhs)
    {   op_with(rhs, std::set_intersection<InIt, InIt, OutIt>); }

    void  or_with(const Row* rhs)
    {   op_with(rhs, std::set_union       <InIt, InIt, OutIt>); }

    void but_with(const Row* rhs)
    {   op_with(rhs, std::set_difference  <InIt, InIt, OutIt>); }


private:
    std::list<int> ids;

};


class InvertedIndex
{
public:

    int add_document(const char* document)
    {
        int id = documents.size();
        documents.push_back(document);
        return id;
    }


    void add_token(int id, const char* token)
    {
        indices[token].add_id(id);
    }


    void fetch(const char* token, Row* out) const
    {
        auto it = indices.find(token);
        if (it != indices.end())
        {   *out = it->second; }
    }


    const char* get_document(int id) const
    {
        return id >= 0 && id < documents.size()
             ? documents[id].c_str()
             : nullptr;
    }


private:

    std::vector<std::string> documents;
    std::unordered_map<std::string, Row> indices;

};
