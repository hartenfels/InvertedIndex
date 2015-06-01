#include <fstream>
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

static constexpr char RECORD_SEP = '\036',
                        UNIT_SEP = '\037';

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
        {   av_push(arr, newSViv(i)); }

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


    void stash(std::ofstream& out)
    {
        for (int i : ids)
        {   out << i << UNIT_SEP; }
    }


private:
    std::list<int> ids;

};


class InvertedIndex
{
public:

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


    void stash(const char* path)
    {
        std::ofstream out(path);
        if (!out)
        {
            warn("Couldn't write to stash.\n");
            return;
        }

        for (auto pair : indices)
        {
            out << pair.first << UNIT_SEP;
            pair.second.stash(out);
            out << RECORD_SEP;
        }
    }


    bool unstash(const char* path)
    {
        std::ifstream in(path);
        if (!in)
        {
            warn("Couldn't read from stash.\n");
            return false;
        }

        while (in)
        {
            std::string token;
            std::getline(in, token, UNIT_SEP);
            while (in && in.peek() != RECORD_SEP)
            {
                std::string id;
                std::getline(in, id, UNIT_SEP);
                indices[token].add_id(atoi(id.c_str()));
            }
            in.ignore();
        }

        return true;
    }


private:

    std::unordered_map<std::string, Row> indices;

};
